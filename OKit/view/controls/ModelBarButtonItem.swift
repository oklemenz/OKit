//
//  ModelBarButtonItem.swift
//  OKit
//
//  Created by Oliver Klemenz on 12.03.19.
//  Copyright © 2020 Oliver Klemenz. All rights reserved.
//

import Foundation
import UIKit

@objc
public protocol ModelBarButtonItemDelegate: AnyObject {
    
    func didTapBarButtonItem(_ barButtonItem: ModelBarButtonItem)
}

@objc
@objcMembers
open class ModelBarButtonItem: UIBarButtonItem {
    
    internal var managed: Bool = false
    
    internal var internalContext: ModelEntity?
    open var modelContext: ModelEntity? {
        get {
            return internalContext ?? Model.getDefault()
        }
        set {
            internalContext = newValue
        }
    }

    open var effectiveContext: ModelEntity? {
        if !contextPath.isEmpty {
            return modelContext?.resolve(contextPath)
        }
        return modelContext
    }
    
    @IBInspectable open var contextPath: String = "" {
        didSet {
            update()
        }
    }
    @IBInspectable open var tapPath: String = "" {
        didSet {
            update()
        }
    }
    @IBInspectable open var enabledPath: String = "" {
        didSet {
            update()
        }
    }
    
    open func context(_ context: ModelEntity?, owner: AnyObject?) {
        self.modelContext = context
        if let owner = owner as? ModelBarButtonItemDelegate, !tapPath.isEmpty {
            target = owner
            action = NSSelectorFromString("didTapBarButtonItem:")
            accessibilityIdentifier = tapPath
        }
        update()
    }
    
    open func update() {
        isEnabled = !enabledPath.isEmpty ? (effectiveContext?.getBool(enabledPath) ?? true) : true
    }
}
