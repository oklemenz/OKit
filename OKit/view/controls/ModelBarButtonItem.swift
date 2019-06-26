//
//  ModelBarButtonItem.swift
//  OKit
//
//  Created by Klemenz, Oliver on 12.03.19.
//  Copyright © 2019 Klemenz, Oliver. All rights reserved.
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
    open var context: ModelEntity? {
        get {
            return internalContext ?? Model.getDefault()
        }
        set {
            internalContext = newValue
        }
    }

    open var effectiveContext: ModelEntity? {
        if !contextPath.isEmpty {
            return context?.resolve(contextPath)
        }
        return context
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
        self.context = context
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
