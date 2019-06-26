//
//  ModelConfig.swift
//  OKit
//
//  Created by Klemenz, Oliver on 06.06.19.
//  Copyright © 2019 Klemenz, Oliver. All rights reserved.
//

import Foundation

@objc(ModelSettings)
open class ModelSettings: Model, Codable {
    
    var darkMode: Bool {
        get {
            return themeName == ModelTheme.dark
        }
        set {
            themeName = newValue ? ModelTheme.dark : ModelTheme.default
        }
    }
    
    var themeName: String = ""
    var encryption: Bool = true
    var protection: Bool = true
    var protectionTimeout: ModelRef = ModelRef(refKey: "5")
    
    var timeouts: [ModelProtectionTimeout] = {
        return [
            ModelProtectionTimeout(code: "0", name: "Immediately".localized),
            ModelProtectionTimeout(code: "1", name: "1 Minute".localized),
            ModelProtectionTimeout(code: "5", name: "5 Minutes".localized),
            ModelProtectionTimeout(code: "10", name: "10 Minutes".localized),
        ]
    }()
}

@objc(ModelProtectionTimeout)
open class ModelProtectionTimeout: ModelEntity, Codable {
    
    var id: String!
    var name: String = ""
    
    public required init() {
        super.init()
    }
    
    public convenience init(code: String, name: String) {
        self.init()
        self.id = code
        self.name = name
    }
    
}

