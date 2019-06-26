//
//  ModelEntityRef.swift
//  ModelBasedApp
//
//  Created by Klemenz, Oliver on 22.03.19.
//  Copyright © 2019 Klemenz, Oliver. All rights reserved.
//

import Foundation

let DefaultModelRefClass: String = "ModelRef"

@objc(ModelRef)
@objcMembers
open class ModelRef: ModelEntity, Codable {
   
    open var id: String!
    open var refKey: String?
    
    open var ref: ModelEntity? {
        if let refKey = refKey {
            return Model.entity(id: refKey)
        }
        return nil
    }

    public static func typeClass(_ type: String? = nil) -> String {
        return !(type ?? "").isEmpty ? type! : DefaultModelRefClass
    }
    
    override open var description: String {
        if let refKey = refKey, let ref = ref {
            return "ref: \(type(of: ref))(\(refKey))"
        }
        return "empty-ref"
    }
    
    public convenience init(refKey: String) {
        self.init()
        self.refKey = refKey
    }
    
}
