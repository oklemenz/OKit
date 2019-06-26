//
//  Crypto.swift
//  OKit
//
//  Created by Klemenz, Oliver on 26.01.17.
//  Copyright © 2017 Klemenz, Oliver. All rights reserved.
//

import Foundation
import CommonCrypto

public class ModelCrypto {
    
    public static var keySize = kCCKeySizeAES256
    public static var blockSize = kCCBlockSizeAES128
    
    public static func saltKey(key: String) -> [UInt8] {
        let bytes = key.utf8.map({$0})
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CC_SHA256(bytes, CC_LONG(bytes.count), &hash)
        return hash
    }
    
    public static func hash(_ text: String) -> String {
        let data = text.data(using:String.Encoding.utf8)!
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return data.map { String(format: "%02hhx", $0) }.joined()
    }
    
    public static func generateRandom(length: Int) -> [UInt8] {
        var data = Data(count: length)
        let result = data.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, length, $0.baseAddress!)
        }
        if result == errSecSuccess {
            var bytes = [UInt8](repeating: 0, count: length)
            data.copyBytes(to: &bytes, count: length)
            return bytes
        }
        return []
    }
    
    public static func encrypt(_ data: [UInt8], key: [UInt8], iv: [UInt8]) -> [UInt8]? {
        var encryptedBytesCount: size_t = 0
        let encryptData = NSMutableData(length: Int(data.count) + kCCBlockSizeAES128)!
        
        let status = CCCrypt(UInt32(kCCEncrypt),
                             UInt32(kCCAlgorithmAES128),
                             UInt32(kCCOptionPKCS7Padding),
                             key, kCCKeySizeAES256,
                             iv,
                             data, data.count,
                             encryptData.mutableBytes, encryptData.length,
                             &encryptedBytesCount)
        
        if UInt32(status) == UInt32(kCCSuccess) {
            encryptData.length = Int(encryptedBytesCount)
            var encryptedBytes = [UInt8](repeating: 0, count: encryptedBytesCount)
            encryptData.getBytes(&encryptedBytes, length: encryptedBytesCount)
            return encryptedBytes
        }
        
        return nil
    }
    
    public static func decrypt(_ data: [UInt8], key: [UInt8], iv: [UInt8]) -> [UInt8]? {
        var decryptedBytesCount: size_t = 0
        let decryptData = NSMutableData(length: Int(data.count) + kCCBlockSizeAES128)!
        
        let status = CCCrypt(UInt32(kCCDecrypt),
                             UInt32(kCCAlgorithmAES128),
                             UInt32(kCCOptionPKCS7Padding),
                             key, kCCKeySizeAES256,
                             iv,
                             data, data.count,
                             decryptData.mutableBytes, decryptData.length,
                             &decryptedBytesCount)
        
        if UInt32(status) == UInt32(kCCSuccess) {
            decryptData.length = Int(decryptedBytesCount)
            var decryptedBytes = [UInt8](repeating: 0, count: decryptedBytesCount)
            decryptData.getBytes(&decryptedBytes, length: decryptedBytesCount)
            return decryptedBytes
        }
        
        return nil
    }
    
    public static func toBase64(_ bytesArray: [UInt8]) -> String {
        return Data(bytesArray).base64EncodedString()
    }
    
    public static func fromBase64(_ base64: String) -> [UInt8]? {
        guard let data = Data(base64Encoded: base64) else {
            return nil
        }
        var bytes = [UInt8]()
        bytes.append(contentsOf: data)
        return bytes
    }
}
