//
//  ModelBinding.swift
//  OKit
//
//  Created by Klemenz, Oliver on 12.03.19.
//  Copyright © 2020 Klemenz, Oliver. All rights reserved.
//

import Foundation
import UIKit

public typealias ModelCompletion = (Bool) -> ()

@objc
public protocol ModelContext {
    func context(_ context: ModelEntity?, owner: AnyObject?)
}

/**
 # Constant: '#xyz'
 # Localized Constant: '%xyz'
 # Model: 'xyz>'
 # Path: '/'
 # Absolute: '/x/y/z'
 # Relative: 'x/y/z'
 # Self: '.'
 # Parent: '..'
 # Root: '<' or '~'
 # Bool Negation: '!xyz'
 # Reference: '$xyz'
 # Function: 'xyz()'
 # Function with Parameter: 'xyz(/a/b)'
 # Index: xy[0]/z
 # KeyPath: 'a.b.c@avg.d
 # Multiple: 'x/y,/a/b'
 # Example: /a/b/../c()/d[1]/e()/f
 */
extension ModelEntity {

    open func get(_ path: String) -> Any? {
        return process(path).value
    }
    
    open func getString(_ path: String) -> String? {
        let values = getStrings(path)
        if values.count == 1 {
            if let value = values[0] {
                return value
            }
        } else if values.count > 1 {
            return values.map({ (value) -> String in
                return value ?? ""
            }).joined(separator: " ")
        }
        return nil
    }
    
    open func getStringAll(_ path: String) -> Any? {
        if path.multiParts.count == 1 {
            return get(path)
        } else {
            return getString(path)
        }
    }
    
    open func getBool(_ path: String) -> Bool {
        var boolPath = path
        var negate: Bool = false
        if boolPath.hasPrefix("!") {
            boolPath = String(boolPath.dropFirst())
            negate = true
        }
        let value = get(boolPath)
        var boolValue: Bool = false
        if let value = value as? Bool {
            boolValue = value
        } else if let value = value as? String {
            boolValue = !value.isEmpty && value != "false" && value != "no" && value != "0"
        } else if let value = value as? NSNumber {
            boolValue = value != 0
        } else if value != nil {
            boolValue = true
        }
        return negate ? !boolValue : boolValue
    }
    
    open func getInt(_ path: String) -> Int? {
        let value = get(path)
        if let value = value as? Int {
            return value
        } else if let value = value {
            return Int("\(value)")
        }
        return nil
    }
    
    open func getFloat(_ path: String) -> Float? {
        let value = get(path)
        if let value = value as? Float {
            return value
        } else if let value = value {
            return Float("\(value)")
        }
        return nil
    }
    
    open func getDouble(_ path: String) -> Double? {
        let value = get(path)
        if let value = value as? Double {
            return value
        } else if let value = value {
            return Double("\(value)")
        }
        return nil
    }
    
    open func getImage(_ path: String) -> UIImage? {
        let value = get(path)
        if let image = value as? ModelImage {
            return  image.image
        } else if let image = value as? ModelInlineImage {
            return image.image
        } else if let image = value as? UIImage {
            return image
        } else if let imageName = value as? String {
            return UIImage(named: imageName)
        }
        return nil
    }
    
    open func getAll(_ path: String) -> [Any?] {
        var result: [Any?] = []
        for part in path.multiParts {
            result.append(get(part))
        }
        return result
    }
    
    open func getStrings(_ path: String) -> [String?] {
        var result: [String?] = []
        for part in path.multiParts {
            let value = get(part)
            if let stringValue = value as? String {
                result.append(stringValue)
            } else if let value = value {
                result.append("\(value)")
            }
        }
        return result
    }
    
    open func set(_ path: String, _ value: Any?, suppressInvalidate: Bool = false) {
        _ = process(path, set: true, value, suppressInvalidate: suppressInvalidate)
    }
    
    open func call(_ path: String, completion: ModelCompletion? = nil, suppressInvalidate: Bool = false) {
        _ = process(path, completion: completion, suppressInvalidate: suppressInvalidate)
    }
    
    open func callSet(_ path: String, _ value: Any? = nil, completion: ModelCompletion? = nil, suppressInvalidate: Bool = false) {
        _ = process(path, set: true, value, completion: completion, suppressInvalidate: suppressInvalidate)
    }
    
    open func resolve(_ path: String) -> ModelEntity? {
        return process(path).context
    }
    
    open func resolve(path: String, subPath: String? = nil) -> [ModelEntity] {
        return process(ModelEntity.combinePaths(path, subPath)).contexts
    }
    
    public static func combinePaths(_ path1: String, _ path2: String?) -> String {
        if let path2 = path2, !path2.isEmpty {
            if path1.isEmpty {
                return path2
            } else if path1.hasSuffix("/") {
                return "\(path1)\(path2)"
            } else {
                return "\(path1)/\(path2)"
            }
        } else {
            return path1
        }
    }
    
    open func process(_ path: String, set: Bool? = false, _ value: Any? = nil, completion: ModelCompletion? = nil, suppressInvalidate: Bool = false) -> (context: ModelEntity?, contexts: [ModelEntity], path: String?, value: Any?) {
        var contexts: [ModelEntity] = []
        var context: ModelEntity? = self
        var contextPath = path.trimmingCharacters(in: .whitespacesAndNewlines)
        if contextPath.isEmpty {
            return (nil, [self], nil, nil)
        }
        var model: Model? = Model.getDefault()
        if contextPath.hasPrefix("#") {
            return (nil, [], nil, String(contextPath.dropFirst()))
        }
        if contextPath.hasPrefix("%") {
            return (nil, [], nil, String(contextPath.dropFirst()).localized)
        }
        if let modelIndex = contextPath.firstIndex(of: ">") {
            let modelName = String(contextPath.prefix(upTo: modelIndex))
            model = Model.get(modelName) ?? Model.getDefault()
            contextPath = String(contextPath.dropFirst(modelName.count + 1))
        }
        if contextPath.hasPrefix("/") {
            context = model
            contextPath = String(contextPath.dropFirst())
        }
        var result: Any?
        var subPath: String?
        let parts = contextPath.bindingParts
        if let context = context {
            contexts.append(context)
        }
        for (index, part) in parts.enumerated() {
            let part = Substring(part.trimmingCharacters(in: .whitespacesAndNewlines))
            if part == "." || part == "" {
                // Self
                result = context
            } else if part == ".." {
                // Parent
                context = context?.parent
                result = context
            } else if part == "<" || part == "~" {
                // Root
                context = context?.model
                result = context
            } else if part.hasPrefix("$") {
                let refPath = String(part.dropFirst())
                result = context?.refAt(path: refPath)
            } else if part.hasSuffix("()") {
                // Function
                let selector = String(part.dropLast(2))
                if set == true, index == parts.count-1 {
                    if !(result is ModelEntity), let object = result as? NSObject {
                        result = context?.setCall(object: object, selector, value, completion: completion, suppressInvalidate: suppressInvalidate)
                    } else {
                        result = context?.setCall(selector, value, completion: completion, suppressInvalidate: suppressInvalidate)
                    }
                } else {
                    if !(result is ModelEntity), let object = result as? NSObject {
                        result = context?.getCall(object: object, selector, completion: completion, suppressInvalidate: suppressInvalidate)
                    } else {
                        result = context?.getCall(selector, completion: completion, suppressInvalidate: suppressInvalidate)
                    }
                }
            } else if set == false && part.firstIndex(of: "(") != nil {
                // Function with Parameter
                var paramPath: String = ""
                var selector = part
                if let indexStart = part.firstIndex(of: "("), let indexEnd = part.lastIndex(of: ")") {
                    selector = selector[..<indexStart]
                    paramPath = String(part[part.index(indexStart, offsetBy: 1)..<indexEnd])
                }
                let paramValue = get(paramPath)
                if !(result is ModelEntity), let object = result as? NSObject {
                    result = context?.setCall(object: object, String(selector), paramValue, completion: completion, suppressInvalidate: suppressInvalidate)
                } else {
                    result = context?.setCall(String(selector), paramValue, completion: completion, suppressInvalidate: suppressInvalidate)
                }
            } else {
                // Property
                if set == true, index == parts.count-1 {
                    // Set value
                    if !(result is ModelEntity), let object = result as? NSObject {
                        object.setValue(value, forKeyPath: String(part))
                    } else {
                        context?.set(key: String(part), value: value, suppressInvalidate: suppressInvalidate)
                    }
                    result = nil
                } else {
                    // Get value
                    var index: Int?
                    var partRaw = part
                    if let indexStart = part.lastIndex(of: "["), let indexEnd = part.lastIndex(of: "]") {
                        partRaw = partRaw[..<indexStart]
                        index = Int(part[part.index(indexStart, offsetBy: 1)..<indexEnd])
                    }
                    if !(result is ModelEntity), let object = result as? NSObject {
                        result = object.value(forKeyPath: String(partRaw))
                    } else {
                        result = context?.get(key: String(partRaw))
                    }
                    // Array
                    if let array = result as? Array<Any>, let index = index {
                        if index >= 0 && index < array.count {
                            result = array[index]
                        } else {
                            result = nil
                        }
                    }
                }
                if index == parts.count-1 {
                    completion?(true)
                }
            }
            // Context
            if result == nil || result is ModelEntity {
                context = result as? ModelEntity
                if let context = context {
                    contexts.append(context)
                }
                subPath = nil
            } else {
                if subPath == nil {
                    subPath = String(part)
                } else {
                    subPath = "\(subPath!)/\(String(part))"
                }
            }
        }
        return (context: context, contexts: contexts, path: subPath, value: result)
    }
    
}
