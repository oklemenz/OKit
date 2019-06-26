//
//  ModelKeychainAccess.swift
//  ModelBasedApp
//
//  Created by Klemenz, Oliver on 01.03.19.
//  Copyright © 2019 Klemenz, Oliver. All rights reserved.
//
import Foundation

public struct ModelKeychainAccess {
    
    public enum KeychainError: Error {
        case noData
        case unexpectedData
        case unexpectedError(status: OSStatus)
    }
    
    private let service: String
    private let useBiometrics: Bool
    private let prompt: String?
    
    public init(service: String, useBiometrics: Bool = true, prompt: String? = nil) {
        self.service = service
        self.useBiometrics = useBiometrics
        self.prompt = prompt
    }
    
    public func get(_ key: String) throws -> String  {
        var query = ModelKeychainAccess.query(service: service, key: key)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        if let prompt = prompt {
            query[kSecUseOperationPrompt as String] = prompt as AnyObject?
        }
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        guard status != errSecItemNotFound else {
            throw KeychainError.noData
        }
        guard status == noErr else {
            throw KeychainError.unexpectedError(status: status)
        }
        guard let existingItem = queryResult as? [String : AnyObject],
            let encodedValue = existingItem[kSecValueData as String] as? Data,
            let value = String(data: encodedValue, encoding: String.Encoding.utf8)
        else {
            throw KeychainError.unexpectedData
        }
        return value
    }
    
    public func set(_ value: String, key: String) throws {
        let encodedValue = value.data(using: String.Encoding.utf8)!
        do {
            try _ = get(key)
            var attributesToUpdate = [String : AnyObject]()
            attributesToUpdate[kSecValueData as String] = encodedValue as AnyObject?
            let query = ModelKeychainAccess.query(service: service, key: key)
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            guard status == noErr else {
                throw KeychainError.unexpectedError(status: status)
            }
        }
        catch KeychainError.noData {
            var newItem = ModelKeychainAccess.query(service: service, key: key)
            if useBiometrics {
                var error: Unmanaged<CFError>?
                let access = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleWhenUnlocked as CFTypeRef, .userPresence, &error)
                newItem[kSecAttrAccessControl as String] = access
            } else {
                newItem[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlocked as AnyObject?
            }
            newItem[kSecValueData as String] = encodedValue as AnyObject?
            let status = SecItemAdd(newItem as CFDictionary, nil)
            guard status == noErr else {
                throw KeychainError.unexpectedError(status: status)
            }
        }
    }
    
    public func remove(_ key: String) throws {
        let query = ModelKeychainAccess.query(service: service, key: key)
        let status = SecItemDelete(query as CFDictionary)
        guard status == noErr || status == errSecItemNotFound else {
            throw KeychainError.unexpectedError(status: status)
        }
    }
    
    public static func query(service: String, key: String) -> [String : AnyObject] {
        var query = [String : AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = service as AnyObject?
        query[kSecAttrAccount as String] = key as AnyObject?
        return query
    }
}
