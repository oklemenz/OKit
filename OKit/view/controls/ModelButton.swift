//
//  ModelButton.swift
//  OKit
//
//  Created by Oliver Klemenz on 22.03.19.
//  Copyright © 2020 Oliver Klemenz. All rights reserved.
//

import Foundation
import UIKit

@objc
public protocol ModelButtonDelegate: AnyObject {
    
    @objc
    func didTapButton(_ button: ModelButton)
}

@objc
@objcMembers
open class ModelButton: UIButton {
    
    internal var managed: Bool = false
    internal var editing: Bool = false
    internal var indexPath: IndexPath?
    
    internal var internalContext: ModelEntity?
    @IBInspectable open var contextPath: String = "" {
        didSet {
            update()
        }
    }
    @IBInspectable open var iconPath: String = "" {
        didSet {
            update()
        }
    }
    @IBInspectable open var titlePath: String = "" {
        didSet {
            update()
        }
    }
    @IBInspectable open var tapPath: String = "" {
        didSet {
            update()
        }
    }
    @IBInspectable open var showPath: String = "" {
        didSet {
            update()
        }
    }
    @IBInspectable open var enabledPath: String = "" {
        didSet {
            update()
        }
    }
}

extension ModelButton {
    
    override open func context(_ context: ModelEntity?, owner: AnyObject?) {
        super.context(context, owner: owner)
        if let owner = owner as? ModelButtonDelegate, !tapPath.isEmpty {
            removeTarget(nil, action: nil, for: .allEvents)
            addTarget(owner, action: NSSelectorFromString("didTapButton:"), for: .touchUpInside)
            accessibilityIdentifier = tapPath
        }
    }
    
    override open func update() {
        if !iconPath.isEmpty {
            let image = effectiveContext?.getImage(iconPath)
            adjustsImageWhenHighlighted = false
            setImage(image, for: .normal)
            setImage(image?.imageWithAlpha(alpha: 0.25)?.withRenderingMode(.alwaysTemplate), for: .highlighted)
        }
        if !titlePath.isEmpty {
            setTitle(effectiveContext?.getString(titlePath), for: .normal)
            setTitleColor(UIColor.tint, for: .normal)
            setTitleColor(UIColor.tint.withAlphaComponent(0.25), for: .highlighted)
        }
        sizeToFit()
        isEnabled = !enabledPath.isEmpty ? (effectiveContext?.getBool(enabledPath) ?? true) : true
        isHidden = !(!showPath.isEmpty ? (effectiveContext?.getBool(showPath) ?? true) : true)
    }
    
    override open func tintColorDidChange() {
        update()
    }
}
