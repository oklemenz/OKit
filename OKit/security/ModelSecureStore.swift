//
//  ModelSecureStore.swift
//  OKit
//
//  Created by Klemenz, Oliver on 20.01.17.
//  Copyright © 2017 Klemenz, Oliver. All rights reserved.
//

import Foundation
import UIKit
import LocalAuthentication

open class ModelSecureStore {

    public static let SecureStoreInit = "\(OKitNamespace).SecureStoreInit"
    public static let BiometricsField = "\(OKitNamespace).UseBiometrics"
    public static let CryptInfoField  = "\(OKitNamespace).CryptInfo"
    
    public enum SecureStoreError: Error {
        case notOpen
    }
    
    public static let instance = ModelSecureStore()
    
    private var key: [UInt8] = []
    private var iv: [UInt8] = []
    private(set) var isOpen: Bool = false
    
    public func open(_ completion: ModelCompletion?) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            try? self._open()
            DispatchQueue.main.async {
                completion?(self.isOpen)
            }
        }
    }
    
    private func _open() throws {
        if !isOpen {
            var cryptInfo: String?
            if ModelSecureStore.initialized() {
                if ModelSecureStore.isDevice {
                    let keychain = ModelKeychainAccess(service: OKitNamespace, prompt: "Access your data".localized)
                    cryptInfo = try keychain.get(ModelSecureStore.CryptInfoField)
                } else {
                    cryptInfo = UserDefaults.standard.string(forKey: ModelSecureStore.CryptInfoField)
                }
            }
            if let cryptInfo = cryptInfo {
                if let cryptInfoJSON = cryptInfo.data(using: .utf8) {
                    if let cryptInfoJSON = try? JSONSerialization.jsonObject(with: cryptInfoJSON) as? [String: Any] {
                        key = cryptInfoJSON["key"] as! [UInt8]
                        iv = cryptInfoJSON["iv"] as! [UInt8]
                    }
                }
            } else {
                key = ModelCrypto.generateRandom(length: ModelCrypto.keySize)
                iv = ModelCrypto.generateRandom(length: ModelCrypto.blockSize)
                try storeCryptInfo(key: key, iv: iv)
            }
            isOpen = !key.isEmpty && !iv.isEmpty
        }
    }
    
    private func storeCryptInfo(key: [UInt8], iv: [UInt8]) throws {
        let cryptInfoRaw: [String:[UInt8]] = [
            "key": key,
            "iv": iv
        ]
        let cryptInfoJSON = try JSONSerialization.data(withJSONObject: cryptInfoRaw)
        let cryptInfo = String(data: cryptInfoJSON, encoding: .utf8)!
        if ModelSecureStore.isDevice {
            let keychain = ModelKeychainAccess(service: OKitNamespace, useBiometrics: ModelSecureStore.biometricsUsed)
            // Remove key first, otherwise authentication will be triggered on existing item (=> prompt)
            try keychain.remove(ModelSecureStore.CryptInfoField)
            try keychain.set(cryptInfo, key: ModelSecureStore.CryptInfoField)
        } else {
            UserDefaults.standard.set(cryptInfo, forKey: ModelSecureStore.CryptInfoField)
            UserDefaults.standard.synchronize()
        }
    }
    
    public func close() {
        iv = []
        key = []
        isOpen = false
    }
    
    public func store(file: URL, data: Data?) throws {
        if isOpen {
            if let data = data {
                if let encryptedBytes = ModelCrypto.encrypt([UInt8](data), key: key, iv: iv) {
                    try Data(encryptedBytes).writeFile(url: file)
                    ModelSecureStore.setInitialized()
                }
            } else {
                try? Data.deleteFile(url: file)
                ModelSecureStore.setInitialized()
            }
        } else {
            throw SecureStoreError.notOpen
        }
    }
    
    public func load(file: URL) throws -> Data? {
        if isOpen {
            if let data = try Data.readFile(url: file) {
                var bytes = [UInt8]()
                bytes.append(contentsOf: data)
                if let decryptedBytes = ModelCrypto.decrypt(bytes, key: key, iv: iv) {
                    return Data(decryptedBytes)
                }
            }
        } else {
            throw SecureStoreError.notOpen
        }
        return nil
    }

    public func storeHttp(url: URL, data: Data?) throws {
        if isOpen {
            if let data = data {
                if let encryptedBytes = ModelCrypto.encrypt([UInt8](data), key: key, iv: iv) {
                    try Data(encryptedBytes).writeHttp(url: url, contentType: "application/octet-stream")
                    ModelSecureStore.setInitialized()
                }
            } else {
                try Data.deleteHttp(url: url)
                ModelSecureStore.setInitialized()
            }
        } else {
            throw SecureStoreError.notOpen
        }
    }
    
    public func loadHttp(url: URL) throws -> Data? {
        if isOpen {
            if let data = try Data.readHttp(url: url) {
                var bytes = [UInt8]()
                bytes.append(contentsOf: data)
                if let decryptedBytes = ModelCrypto.decrypt(bytes, key: key, iv: iv) {
                    return Data(decryptedBytes)
                }
            }
        } else {
            throw SecureStoreError.notOpen
        }
        return nil
    }
    
    private static func setInitialized() {
        UserDefaults.standard.set(true, forKey: SecureStoreInit)
        UserDefaults.standard.synchronize()
    }
    
    public static func initialized() -> Bool {
        return UserDefaults.standard.bool(forKey: SecureStoreInit)
    }
    
    public static var isDevice: Bool {
        return TARGET_OS_SIMULATOR == 0
    }

    public func setBiometrics(_ state: Bool) throws {
        guard ModelSecureStore.isDevice && ModelSecureStore.authEnabled() else {
            return
        }
        do {
            UserDefaults.standard.set(state, forKey: ModelSecureStore.BiometricsField)
            UserDefaults.standard.synchronize()
            if isOpen {
                try storeCryptInfo(key: key, iv: iv)
            }
            throw SecureStoreError.notOpen
        } catch {
            throw SecureStoreError.notOpen
        }
    }
    
    public static var biometricsUsed : Bool {
        return isDevice && authEnabled() && !(UserDefaults.standard.value(forKey: BiometricsField) as? Bool == false)
    }
    
    public static func biometricsEnabled() -> Bool {
        return LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    public static func biometricsText() -> String {
        let laContext = LAContext()
        laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        if laContext.biometryType == .touchID {
            return "Use Touch ID".localized
        } else if laContext.biometryType == .faceID {
            return "Use Face ID".localized
        }
        return "Use Touch ID".localized
    }
    
    public static func passcodeEnabled() -> Bool {
        return LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
    }
    
    public static func authEnabled() -> Bool {
        return biometricsEnabled() || passcodeEnabled()
    }
}
