//
//  ModelSwitchCell.swift
//  OKit
//
//  Created by Klemenz, Oliver on 03.04.19.
//  Copyright © 2020 Klemenz, Oliver. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
open class ModelSwitchCell: ModelEditCell {

    @IBOutlet open var control: UISwitch?
    
    @IBInspectable open var onPath: String = "" {
        didSet {
            updateOn()
        }
    }
    
    deinit {
        control?.removeTarget(self, action: nil, for: .allEvents)
    }
    
    open override func setup() {
        prepareControl(control)
        control = control ?? UISwitch()
        accessoryView = control
        editingAccessoryView = control
        control?.addTarget(self, action: #selector(setOn), for: .valueChanged)
    }
   
    override open func updateEdit() {
        super.updateEdit()
        control?.isEnabled = effectiveEdit
    }

    override open func update() {
        super.update()
        updateOn()
    }
    
    override open func updateControlInDisplay() {
        super.updateControlInDisplay()
        accessoryView = control
        if !controlInDisplay.isEmpty && effectiveContext?.getBool(controlInDisplay) == false {
            accessoryView = nil
        }
    }
    
    // MARK: - isOn
    @objc
    open func setOn() {
        guard !onPath.isEmpty else {
            return
        }
        effectiveContext?.set(onPath, control?.isOn ?? false)
        updateTextValue()
    }

    open func isOn() -> Bool {
        guard !onPath.isEmpty else {
            return false
        }
        return effectiveContext?.getBool(onPath) == true
    }
    
    open func updateOn() {
        guard !onPath.isEmpty else {
            return
        }
        control?.isOn = isOn()
    }
}

