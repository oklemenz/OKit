//
//  ModelEntity.swift
//  OKit
//
//  Created by Klemenz, Oliver on 27.02.19.
//  Copyright © 2019 Klemenz, Oliver. All rights reserved.
//

import Foundation
import UIKit

@objc
@objcMembers
open class ModelEntity: NSObject {
    
    open var parent: ModelEntity?
    open weak var delegate: ModelPartial?

    open var model: Model? {
        if self is Model {
            return self as? Model
        }
        if let parent = parent {
            return parent.model
        }
        return nil
    }
    
    open var key: String? {
        return value(forKey: "id") as? String
    }

    internal var _pending: Bool = false

    public required override init() {
        super.init()
        if key == nil {
            setValue(UUID().uuidString, forKey: "id")
        }
    }
}

extension ModelEntity {
    
    open func isPending() -> Bool {
        return _pending || Model.forceStore || Model.importActive || Model.exportActive
    }
    
    open func setPending() {
        _pending = true
        parent?.setPending()
    }
    
    open func clearPending() {
        _pending = false
    }
    
    open dynamic func managed(_ context: Any? = nil) {
    }
    
    open dynamic func unmanaged(_ context: Any? = nil) {
    }
    
    open func isManaged() -> Bool {
        return Model.isManaged(self)
    }
    
    open func isUnmanaged() -> Bool {
        return Model.isUnmanaged(self)
    }
}

extension ModelEntity {
    
    open func refAt(path: String) -> ModelEntity? {
        if let refKey = get(path) as? String, !refKey.isEmpty {
            return Model.entity(id: refKey)
        }
        return nil
    }
        
    open func assign(path: String, entity: ModelEntity?) {
        let previousValue = get(path)
        let previousEntity = previousValue as? ModelEntity
        guard previousEntity != entity else {
            return
        }
        if let previousEntity = previousEntity {
            model?.unmanage(previousEntity)
            set(path, nil)
            previousEntity.unmanaged(self)
        }
        if let entity = entity {
            model?.manage(entity, parent: self)
            set(path, entity)
            entity.managed(self)
        }
    }
    
    open func unassign(path: String) {
        assign(path: path, entity: nil)
    }
    
    open func assign(key: String, entity: ModelEntity?) {
        let previousValue = value(forKey: key)
        let previousEntity = previousValue as? ModelEntity
        guard previousEntity != entity else {
            return
        }
        if let previousEntity = previousEntity {
            model?.unmanage(previousEntity)
            setValue(nil, forKeyPath: key)
            previousEntity.unmanaged(self)
        }
        if let entity = entity {
            model?.manage(entity, parent: self)
            setValue(entity, forKeyPath: key)
            entity.managed(self)
        }
    }
    
    open func unassign(key: String) {
        assign(key: key, entity: nil)
    }
    
    open func add(path: String, entity: ModelEntity, append: Bool = false, key: String? = nil) {
        if var array = get(path) as? Array<ModelEntity> {
            add(&array, entity: entity, append: append)
        }
        if var set = get(path) as? Set<ModelEntity> {
            add(&set, entity: entity)
        }
        if var dict = get(path) as? Dictionary<String, ModelEntity>, let key = key {
            add(&dict, entity: entity, key: key)
        }
    }

    open func add(_ array: inout Array<ModelEntity>, entity: ModelEntity, append: Bool = false) {
        model?.manage(entity, parent: self)
        if append {
            array.append(entity)
        } else {
            array.insert(entity, at: 0)
        }
        entity.managed(self)
    }
    
    open func add(_ array: inout Array<ModelEntity>, type: String, append: Bool = false) -> ModelEntity {
        let entity = ModelEntity.create(type)
        add(&array, entity: entity, append: append)
        return entity
    }

    open func remove(_ array: inout Array<ModelEntity>, entity: ModelEntity?) -> Int? {
        if let entity = entity, let index = array.firstIndex(of: entity) {
            model?.unmanage(entity)
            array.remove(at: index)
            entity.unmanaged(array)
            return index
        }
        return nil
    }
    
    open func clear(_ array: inout Array<ModelEntity>) {
        for entity in array {
            _ = remove(&array, entity: entity)
        }
    }
    
    open func add(_ set: inout Set<ModelEntity>, entity: ModelEntity) {
        model?.manage(entity, parent: self)
        set.insert(entity)
        entity.managed(set)
    }
    
    open func add(_ set: inout Set<ModelEntity>, type: String) -> ModelEntity {
        let entity = ModelEntity.create(type)
        add(&set, entity: entity)
        return entity
    }
    
    open func remove(_ set: inout Set<ModelEntity>, entity: ModelEntity?) {
        if let entity = entity {
            model?.unmanage(entity)
            set.remove(entity)
            entity.unmanaged(set)
        }
    }
    
    open func clear(_ set: inout Set<ModelEntity>) {
        for entity in set {
            _ = remove(&set, entity: entity)
        }
    }
    
    open func add(_ dict: inout Dictionary<String, ModelEntity>, entity: ModelEntity, key: String) {
        model?.manage(entity, parent: self)
        dict[key] = entity
        entity.managed(dict)
    }
    
    open func add(_ dict: inout Dictionary<String, ModelEntity>, type: String, key: String) -> ModelEntity {
        let entity = ModelEntity.create(type)
        add(&dict, entity: entity, key: key)
        return entity
    }
    
    open func remove(_ dict: inout Dictionary<String, ModelEntity>, key: String) {
        if let entity = dict[key] as ModelEntity? {
            model?.unmanage(entity)
            dict.removeValue(forKey: key)
            entity.unmanaged(dict)
        }
    }
    
    open func clear(_ dict: inout Dictionary<String, ModelEntity>) {
        for entry in dict {
            _ = remove(&dict, key: entry.key)
        }
    }
    
    open func modelType<T: Model>() -> T.Type? {
        if let model = self.model {
            return type(of: model) as? T.Type
        }
        return nil
    }
    
    static public func create(_ type: String) -> ModelEntity {
        let modelType = NSClassFromString(type) as! NSObject.Type
        return modelType.init() as! ModelEntity
    }
    
    static public func createRef(_ type: String? = nil) -> ModelRef {
        return create(ModelRef.typeClass(type)) as! ModelRef
    }
    
    override open func value(forUndefinedKey key: String) -> Any? {
        return nil
    }
    
    override open func setValue(_ value: Any?, forUndefinedKey key: String) {
    }

    override open func value(forKey key: String) -> Any? {
        return super.value(forKey: key)
    }
    
    override open func value(forKeyPath keyPath: String) -> Any? {
        return super.value(forKeyPath: keyPath)
    }
    
    override open func setValue(_ value: Any?, forKey key: String) {
        super.setValue(value, forKey: key)
    }
    
    override open func setValue(_ value: Any?, forKeyPath keyPath: String) {
        super.setValue(value, forKeyPath: keyPath)
    }
    
    open func get(key: String) -> Any? {
        return value(forKeyPath: key)
    }
    
    open func set(key: String, value: Any?, suppressInvalidate: Bool = false) {
        if let entity = value as? ModelEntity {
            assign(key: key, entity: entity)
        } else if value == nil && get(key: key) is ModelEntity {
            unassign(key: key)
        } else {
            let effectiveValue = self.value(forKey: key) is String && !(value is String) ? "\(value ?? "")" : value
            setValue(effectiveValue, forKeyPath: key)
        }
        if !suppressInvalidate {
            invalidate(key: key)
        }
    }
    
    open func setCall(_ selector: String, _ value: Any? = nil, completion: ModelCompletion? = nil, suppressInvalidate: Bool = false) -> Any? {
        return setCall(object: self, selector, value, completion: completion, suppressInvalidate: suppressInvalidate)
    }
    
    open func setCall(object: NSObject, _ selector: String, _ value: Any? = nil, completion: ModelCompletion? = nil, suppressInvalidate: Bool = false) -> Any? {
        var selectorName = NSSelectorFromString("\(selector):completion:")
        if object.responds(to: selectorName) {
            return object.perform(selectorName, with: value, with: { (completed: Bool) -> () in
                if object == self && !suppressInvalidate {
                    self.invalidate()
                }
                completion?(completed)
            })?.takeUnretainedValue()
        } else {
            selectorName = NSSelectorFromString("\(selector):")
            if object.responds(to: selectorName) {
                let result = object.perform(selectorName, with: value)?.takeUnretainedValue()
                if object == self && !suppressInvalidate {
                    invalidate()
                }
                completion?(true)
                return result
            }
        }
        return nil
    }
    
    open func getCall(_ selector: String, completion: ModelCompletion? = nil, suppressInvalidate: Bool = false) -> Any? {
        return getCall(object: self, selector, completion: completion, suppressInvalidate: suppressInvalidate)
    }
    
    open func getCall(object: NSObject, _ selector: String, completion: ModelCompletion? = nil, suppressInvalidate: Bool = false) -> Any? {
        var selectorName = NSSelectorFromString("\(selector):")
        if object.responds(to: selectorName) {
            return object.perform(selectorName, with: { (completed: Bool) -> () in
                if object == self && !suppressInvalidate {
                    self.invalidate()
                }
                completion?(completed)
            })?.takeUnretainedValue()
        } else {
            selectorName = NSSelectorFromString("\(selector)WithCompletion:")
            if object.responds(to: selectorName) == true {
                return object.perform(selectorName, with: { (completed: Bool) -> () in
                    if object == self && !suppressInvalidate {
                        self.invalidate()
                    }
                    completion?(completed)
                })?.takeUnretainedValue()
            } else {
                selectorName = NSSelectorFromString(selector)
                if object.responds(to: selectorName) == true {
                    let result = object.perform(selectorName)?.takeUnretainedValue()
                    if object == self && !suppressInvalidate {
                        self.invalidate()
                    }
                    completion?(true)
                    return result
                }
            }
        }
        return nil
    }
    
    open func invalidate(key: String? = nil) {
        invalidated(key: key)
        setPending()
        delegate?.sync(entity: self)
        delegate?.setPending()
        DispatchQueue.main.async {
            UIApplication.invalidate(self, key: key)
            UIApplication.invalidate(self.delegate)
        }
    }
    
    open func invalidated(key: String? = nil) {
    }
}
