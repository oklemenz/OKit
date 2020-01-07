//
//  ModelHybrid.swift
//  OKit
//
//  Created by Oliver Klemenz on 14.03.19.
//  Copyright © 2020 Oliver Klemenz. All rights reserved.
//

import Foundation

@objc
@objcMembers
open class ModelHybrid: ModelEntity {
    
    private var _retrieved: Bool = false
    
    dynamic override open func setPending() {
        _pending = true
    }
    
    dynamic open func store() {
        clearPending()
    }
    
    dynamic open func clear() {
        clearPending()
    }
    
    open func isRetrieved() -> Bool {
        return _retrieved
    }
    
    open func setRetrieved() {
        _retrieved = true
    }
    
    open func read(url: URL?) throws -> Data? {
        if let path = path {
            if Model.importActive {
                return try modelType()?.import(url: path)
            } else {
                return try modelType()?.read(url: path)
            }
        }
        return nil
    }
    
    open func write(url: URL?, data: Data) throws {
        if let path = path {
            if Model.exportActive {
                try modelType()?.export(url: path, data: data)
            } else {
                try modelType()?.write(url: path, data: data)
            }
        }
    }
    
    open func delete(url: URL?) throws {
        if let path = path {
            try modelType()?.delete(url: path)
        }
    }
    
    open var target: URL? {
        return modelType()?.target
    }
    
    open dynamic var path: URL? {
        return nil
    }
}
