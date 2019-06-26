//
//  Data+Extension.swift
//  OKit
//
//  Created by Klemenz, Oliver on 13.03.19.
//  Copyright © 2019 Klemenz, Oliver. All rights reserved.
//

import Foundation

@objc
public extension NSData {
}

public extension Data {

    enum DataError: Error {
        case encryptError
        case httpError
    }
    
    static func readFile(url: URL) throws -> Data? {
        return try Data(contentsOf: url)
    }
    
    func writeFile(url: URL) throws {
        try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
        try write(to: url)
    }
    
    static func deleteFile(url: URL) throws {
        try? FileManager.default.removeItem(at: url)
    }
    
    static func readEncryptedFile(url: URL) throws -> Data? {
        if let data = try ModelSecureStore.instance.load(file: url) {
            return data
        }
        throw DataError.encryptError
    }
    
    func writeEncryptedFile(url: URL) throws {
        try ModelSecureStore.instance.store(file: url, data: self)
    }
    
    static func deleteEncryptedFile(url: URL) throws {
        try ModelSecureStore.instance.store(file: url, data: nil)
    }
    
    static func readHttp(url: URL) throws -> Data? {
        let semaphore = DispatchSemaphore(value: 0)
        var result: Data?
        var resultError: Error?
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            result = data
            resultError = error
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        if let resultError = resultError {
            throw resultError
        }
        return result
    }
    
    func writeHttp(url: URL, contentType: String = "application/json") throws {
        let semaphore = DispatchSemaphore(value: 0)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        var resultError: Error?
        let task = URLSession.shared.uploadTask(with: request, from: self) {(data, response, error) in
            resultError = error
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        if let resultError = resultError {
            throw resultError
        }
    }
    
    static func deleteHttp(url: URL) throws {
        let semaphore = DispatchSemaphore(value: 0)
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        var resultError: Error?
        let task = URLSession.shared.uploadTask(with: request, from: nil) {(data, response, error) in
            resultError = error
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        if let resultError = resultError {
            throw resultError
        }
    }
    
    static func readEncryptedHttp(url: URL) throws -> Data? {
        if let data = try ModelSecureStore.instance.loadHttp(url: url) {
            return data
        }
        throw DataError.httpError
    }
    
    func writeEncryptedHttp(url: URL) throws {
        try ModelSecureStore.instance.storeHttp(url: url, data: self)
    }
    
    static func deleteEncryptedHttp(url: URL) throws {
        try ModelSecureStore.instance.storeHttp(url: url, data: nil)
    }
}

