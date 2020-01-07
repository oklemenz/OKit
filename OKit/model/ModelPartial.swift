//
//  ModelPartition.swift
//  OKit
//
//  Created by Oliver Klemenz on 18.03.19.
//  Copyright © 2020 Oliver Klemenz. All rights reserved.
//

import Foundation

@objc
@objcMembers
open class ModelPartial: ModelHybrid {
    
    public enum ModelError: Error {
        case retrievePartition
        case storePartition
    }
    
    private var _def: ModelEntity?
    public var def: ModelEntity? {
        get {
            return _def
        }
        set {
            if _def != newValue {
                if let previousDef = _def {
                    model?.unmanage(previousDef)
                    _def?.delegate = nil
                    _def = nil
                    previousDef.unmanaged(self)
                }
                if let def = newValue {
                    model?.manage(def, parent: self)
                    _def = def
                    def.delegate = self
                    def.managed(self)
                }
                setPending()
            }
        }
    }
    
    open func retrieve<T: ModelEntity & Codable>(_ type: T.Type) throws -> T? {
        guard !isRetrieved() else {
            return def as? T
        }
        if let jsonData = try? read(url: path) {
            def = try JSONDecoder().decode(type, from: jsonData)
        } else {
            def = type.init()
        }
        clearPending()
        setRetrieved()
        return def as? T
    }
    
    open func store<T: ModelEntity & Codable>(_ entity: T?) throws {
        guard isPending(), let entity = entity else {
            return
        }
        super.store()
        if let jsonData = try? JSONEncoder().encode(entity) {
            try? write(url: path, data: jsonData)
        } else {
            throw ModelError.storePartition
        }
    }
    
    dynamic open func assign(_ entity: ModelEntity?) {
        def = entity
    }
    
    dynamic open func sync(entity: ModelEntity) {
    }
    
    override dynamic open func clear() {
        super.clear()
        try? delete(url: path)
    }
    
    override open var path: URL? {
        return URL(string: "\(model?.modelName != nil ? "\(model!.modelName)/" : "")\(key!).json")!
    }
}
