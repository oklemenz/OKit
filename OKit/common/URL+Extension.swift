//
//  URL+Extension.swift
//  OKit
//
//  Created by Oliver Klemenz on 11.04.19.
//  Copyright © 2020 Oliver Klemenz. All rights reserved.
//

import Foundation

@objc
public extension NSURL {
    
    var isDirectory: Bool {
        return (self as URL).isDirectory
    }
    
    var subDirectories: [URL] {
        return (self as URL).subDirectories
    }
    
    var properties: Dictionary<FileAttributeKey, Any> {
        return (self as URL).properties
    }
    
    func copyFolder(to: URL) throws {
        return try (self as URL).copyFolder(to: to)
    }
    
    func delete() throws {
        return try (self as URL).delete()
    }
}

public extension URL {
    
    var isDirectory: Bool {
        return (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
    
    var subDirectories: [URL] {
        guard isDirectory else { return [] }
        return (try? FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]).filter{ $0.isDirectory }) ?? []
    }

    var properties: Dictionary<FileAttributeKey, Any> {
        return (try? FileManager.default.attributesOfItem(atPath: self.path)) ?? [:]
    }
    
    func copyFolder(to: URL) throws {
        try? FileManager.default.createDirectory(at: to.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
        try FileManager.default.copyItem(at: self, to: to)
        try? FileManager.default.setAttributes([FileAttributeKey.modificationDate: Date()], ofItemAtPath: to.path)
    }
    
    func delete() throws {
        try? FileManager.default.removeItem(at: self)
    }
    
    static var documents: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func path(_ url: URL) -> URL {
        return self.appendingPathComponent(url.path)
    }
}
