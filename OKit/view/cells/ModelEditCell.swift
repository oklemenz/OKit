//
//  ModelEditCell.swift
//  OKit
//
//  Created by Klemenz, Oliver on 03.04.19.
//  Copyright © 2020 Klemenz, Oliver. All rights reserved.
//

import Foundation
import UIKit

open class ModelEditCell: ModelTableCell {
    
    @IBInspectable open var readOnly: String = "#false"
    @IBInspectable open var controlInDisplay: String = "#true" {
        didSet {
            updateControlInDisplay()
        }
    }
    
    open var selectEdit: Bool = false
    open var selectActive: Bool = false {
        didSet {
            updateEdit()
        }
    }
    
    open var effectiveEdit: Bool {
        return isEditing && (!selectEdit || selectActive) && !isReadOnly()
    }
    
    open func isReadOnly() -> Bool {
        return effectiveContext?.getBool(readOnly) == true
    }
    
    override open func update() {
        super.update()
        updateControlInDisplay()
    }
    
    open func updateEdit() {
        let editControlVisible = isEditing && editingAccessoryView !== nil
        UIView.animate(withDuration: 0.25) {
            self.detailTextLabel?.alpha = editControlVisible ? 0.0 : 1.0
        }
    }
    
    override open func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        updateEdit()
    }
    
    open func prepareControl(_ control: UIView?) {
        control?.removeFromSuperview()
        if accessoryView == control {
            accessoryView = nil
        }
        if editingAccessoryView == control {
            editingAccessoryView = nil
        }
    }
    
    open func updateControlInDisplay() {
    }
    
    override open func prepareForInterfaceBuilder() {
        awakeFromNib()
        setNeedsDisplay()
        setNeedsLayout()
    }
}
