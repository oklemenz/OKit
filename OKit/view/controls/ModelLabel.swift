//
//  ModelLabel.swift
//  OKit
//
//  Created by Klemenz, Oliver on 27.03.19.
//  Copyright © 2020 Klemenz, Oliver. All rights reserved.
//

import Foundation
import UIKit

@objc
@objcMembers
open class ModelLabel: UILabel {
    
    internal var managed: Bool = false
    internal var indexPath: IndexPath?
    
    internal var internalContext: ModelEntity?
    @IBInspectable open var contextPath: String = "" {
        didSet {
            update()
        }
    }
    @IBInspectable open var textPath: String = "" {
        didSet {
            update()
        }
    }
    @IBInspectable open var showPath: String = "" {
        didSet {
            update()
        }
    }
}

extension ModelLabel {
    
    override open func update() {
        if !textPath.isEmpty {
            let textValue = effectiveContext?.get(textPath)
            if let attributedText = textValue as? NSAttributedString {
                self.attributedText = attributedText
            } else if let text = textValue as? String {
                self.text = text
            }
        }
        sizeToFit()
        isHidden = !(!showPath.isEmpty ? (effectiveContext?.getBool(showPath) ?? true) : true)
    }
}

