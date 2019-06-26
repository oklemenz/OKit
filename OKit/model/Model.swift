//
//  Model.swift
//  OKit
//
//  Created by Klemenz, Oliver on 27.02.19.
//  Copyright © 2019 Klemenz, Oliver. All rights reserved.
//

import Foundation
import UIKit

let OKitNamespace = "de.oklemenz.okit.secure"

@objc
open class Model: ModelEntity {
    
    public static let Identifier = "model"
    public static let DefaultName = "default"
    
    private static var models: [String:Model] = [:]
    private static var managedEntities: [String:ModelEntity] = [:]
    private static var unmanagedEntities: [String:ModelEntity] = [:]

    private var _name: String = DefaultName
    private var _target: URL!
    private var _path: URL!
    
    open class var target: URL {
        return URL.documents.appendingPathComponent("okit/data")
    }
    
    open class var targetExport: URL {
        return URL.documents.appendingPathComponent("okit/export")
    }

    open class func setDefaults() {
        models.removeAll()
        _ = Model.register(DefaultModel.self)
    }
    
    private static var _secure: Bool = false
    private static var _syncBlock: (() -> ())?
    open class func syncState() {
        _syncBlock?()
    }

    open class func sync() {
        setDefaults()
        syncState()
    }
    
    open class func initialize(_ window: UIWindow?, secure: Bool = false, _ block: (() -> ())? = nil) {
        _secure = secure
        _syncBlock = block
        setDefaults()
        if secure {
            unprotectAndSync();
        } else {
            sync()
        }
        initialized(window)
    }
    
    open class func unprotectAndSync() {
        unprotect() { (_) in
            sync()
        }
    }
    
    open class func initialized(_ window: UIWindow?) {
        UIApplication.instance?.initialized(window: window)
    }
    
    private static var _stateBlock: (() -> ())?
    open class func state(_ block: (() -> ())? = nil) {
        _stateBlock = block
    }
    
    open class func updateState() {
        _stateBlock?()
    }
    
    open class func storeState() {
        updateState()
        Model.protect()
    }
    
    open class func restoreState() {
        Model.unprotect()
    }
    
    internal static var exportActive = false
    open class func exportState() {
        updateState()
        exportActive = true
        updateState()
        exportActive = false
    }
    
    open class func exportClear() {
        try? targetExport.delete()
    }
    
    internal static var importActive = false
    open class func importState() {
        importActive = true
        sync()
        updateState()
        importActive = false
    }
    
    internal static var forceStore = false
    open class func updateAllState() {
        forceStore = true
        updateState()
        forceStore = false
    }
    
    open class func register<T: Model & Codable>(_ type: T.Type, name: String = DefaultName) -> T {
        let path = URL(string: "\(name).json")!
        var model: Model?
        do {
            if importActive {
                model = try Model.retrieve(type, url: path)
            } else {
                model = try type.init().modelType()?.retrieve(type, url: path)
            }
        } catch {
            print("Model '\(name)':", error)
        }
        if model == nil {
            model = type.init()
        }
        model?._name = name
        model?._target = target
        model?._path = path
        model?.manage(model!)
        models[name] = model!
        return model as! T
    }

    open class func getDefault() -> Model? {
        return models[DefaultName]
    }
    
    open class func get(_ name: String) -> Model? {
        if name.isEmpty {
            return getDefault()
        }
        return models[name]
    }
    
    open class func retrieve<T: Codable>(_ type: T.Type, url: URL) throws -> T? {
        if let jsonData = try read(url: url) {
            return try JSONDecoder().decode(T.self, from: jsonData)
        }
        return nil
    }
    
    open class func store<T: Model & Codable>(_ model: T?) {
        guard let model = model else {
            return
        }
        if model.isPending() {
            if let jsonData = try? JSONEncoder().encode(model) {
                if exportActive {
                    try? model.modelType()?.export(url: model._path, data: jsonData)
                } else {
                    try? model.modelType()?.write(url: model._path, data: jsonData)
                }
            }
        }
        for entry in managedEntities {
            let entity = entry.value
            if entity.model == model {
                if let hybridEntity = entity as? ModelHybrid, hybridEntity.isPending() {
                    hybridEntity.store()
                }
                entity.clearPending()
            }
        }
        for entry in unmanagedEntities {
            let entity = entry.value
            if entity.model == model {
                if let hybridEntity = entity as? ModelHybrid {
                    hybridEntity.clear()
                }
                entity.clearPending()
            }
        }
        Model.unmanagedEntities = unmanagedEntities.filter({ (entry) -> Bool in
            let entity = entry.value
            return entity.model != model
        })
    }

    open class func `import`(url: URL) throws -> Data? {
        return try Data.readFile(url: Model.target.path(url))
    }
    
    open class func export(url: URL, data: Data) throws {
        try data.writeFile(url: Model.targetExport.path(url))
    }
    
    open class func read(url: URL) throws -> Data? {
        return try Data.readFile(url: Model.target.path(url))
    }
    
    open class func write(url: URL, data: Data) throws {
        try data.writeFile(url: Model.target.path(url))
    }
    
    open class func delete(url: URL) throws {
        try? Data.deleteFile(url: Model.target.path(url))
    }
    
    internal func manage(_ entity: ModelEntity, parent: ModelEntity? = nil) {
        Model.traverse(entity, context: parent) { (entity, context) in
            entity.parent = context
            Model.register(entity)
        }
    }
    
    internal static func isManaged(_ entity: ModelEntity) -> Bool {
        if let id = entity.key {
            return managedEntities[id] != nil
        }
        return false
    }
    
    internal func unmanage(_ entity: ModelEntity) {
        Model.traverse(entity) { (entity, context) in
            Model.deregister(entity)
        }
    }
    
    internal static func isUnmanaged(_ entity: ModelEntity) -> Bool {
        if let id = entity.key {
            return unmanagedEntities[id] != nil
        }
        return false
    }
    
    private static func register(_ entity: ModelEntity) {
        if let id = entity.key {
            managedEntities[id] = entity
            unmanagedEntities.removeValue(forKey: id)
        }
    }
    
    private static func deregister(_ entity: ModelEntity) {
        if let id = entity.key {
            managedEntities.removeValue(forKey: id)
            unmanagedEntities[id] = entity
        }
    }
    
    internal static func traverse(_ entity: ModelEntity, context: ModelEntity? = nil, visit: (ModelEntity, ModelEntity?) -> ()) {
        visit(entity, context)
        Mirror(reflecting: entity).children.forEach { (child) in
            if let subEntity = child.value as? ModelEntity {
                traverse(subEntity, context: entity, visit: visit)
            }
            if child.value is Array<ModelEntity> {
                for subEntity in child.value as! Array<ModelEntity> {
                    traverse(subEntity, context: entity, visit: visit)
                }
            }
            if child.value is Set<ModelEntity> {
                for subEntity in child.value as! Set<ModelEntity> {
                    traverse(subEntity, context: entity, visit: visit)
                }
            }
            if child.value is Dictionary<String, ModelEntity> {
                for entry in child.value as! Dictionary<String, ModelEntity> {
                    let subEntity = entry.value
                    traverse(subEntity, context: entity, visit: visit)
                }
            }
        }
    }
    
    open func _type<T: Model & Codable>() -> T.Type {
        return type(of: self) as! T.Type
    }
    
    public static func entity(id: String) -> ModelEntity? {
        return managedEntities[id]
    }

    open var modelName: String {
        return _name
    }
    
    open class func protect() {
        if _secure {
            UIApplication.instance?.protect()
        }
    }
    
    open class func unprotect(completion: ModelCompletion? = nil) {
        if _secure {
            UIApplication.instance?.unprotect(completion: completion)
        } else {
            completion?(true)
        }
    }
    
}

@objc
open class DefaultModel: ModelTransient, Codable {
}
