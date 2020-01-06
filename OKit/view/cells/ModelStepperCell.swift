//
//  ModelStepperCell.swift
//  OKit
//
//  Created by Klemenz, Oliver on 02.05.19.
//  Copyright © 2020 Klemenz, Oliver. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
open class ModelStepperCell: ModelEditCell {
    
    @IBOutlet open var control: UIStepper?
    
    @IBInspectable open var valuePath: String = "" {
        didSet {
            updateValue()
        }
    }
    @IBInspectable open var minValuePath: String = "#0" {
        didSet {
            updateMinValue()
        }
    }
    @IBInspectable open var maxValuePath: String = "#100" {
        didSet {
            updateMaxValue()
        }
    }
    @IBInspectable open var stepValuePath: String = "#1" {
        didSet {
            updateStepValue()
        }
    }
    
    deinit {
        control?.removeTarget(self, action: nil, for: .allEvents)
    }
    
    open override func setup() {
        super.setup()
        prepareControl(control)
        control = control ?? UIStepper()
        control?.isContinuous = false
        accessoryView = control
        editingAccessoryView = control
        control?.addTarget(self, action: #selector(setStepperValue), for: .valueChanged)
    }
    
    override open func updateEdit() {
        super.updateEdit()
        control?.isEnabled = effectiveEdit
    }
    
    override open func update() {
        super.update()
        updateValue()
        updateMinValue()
        updateMaxValue()
        updateStepValue()
    }
    
    override open func updateControlInDisplay() {
        super.updateControlInDisplay()
        accessoryView = control
        if !controlInDisplay.isEmpty && effectiveContext?.getBool(controlInDisplay) == false {
            accessoryView = nil
        }
    }
    
    // MARK: - value
    @objc
    open func setValue() {
        guard !valuePath.isEmpty else {
            return
        }
        effectiveContext?.set(valuePath, control?.value ?? getMinValue())
        updateTextValue()
    }
    
    @objc
    open func setStepperValue() {
        setValue()
    }
    
    open func getValue() -> Double {
        guard !valuePath.isEmpty else {
            return 0
        }
        return effectiveContext?.getDouble(valuePath) ?? getMinValue()
    }
    
    open func updateValue() {
        guard !valuePath.isEmpty else {
            return
        }
        control?.value = getValue()
    }
    
    // MARK: - min value
    @objc
    open func setMinValue() {
        guard !minValuePath.isEmpty else {
            return
        }
        effectiveContext?.set(minValuePath, control?.minimumValue ?? 0)
    }
    
    open func getMinValue() -> Double {
        guard !minValuePath.isEmpty else {
            return 0
        }
        return effectiveContext?.getDouble(minValuePath) ?? 0
    }
    
    open func updateMinValue() {
        guard !minValuePath.isEmpty else {
            return
        }
        control?.minimumValue = getMinValue()
    }
    
    // MARK: - max value
    @objc
    open func setMaxValue() {
        guard !maxValuePath.isEmpty else {
            return
        }
        effectiveContext?.set(maxValuePath, control?.maximumValue ?? 100)
    }
    
    open func getMaxValue() -> Double {
        guard !maxValuePath.isEmpty else {
            return 0
        }
        return effectiveContext?.getDouble(maxValuePath) ?? 0
    }
    
    open func updateMaxValue() {
        guard !maxValuePath.isEmpty else {
            return
        }
        control?.maximumValue = getMaxValue()
    }
    
    // MARK: - step value
    @objc
    open func setStepValue() {
        guard !stepValuePath.isEmpty else {
            return
        }
        effectiveContext?.set(stepValuePath, control?.stepValue ?? 1)
    }
    
    open func getStepValue() -> Double {
        guard !stepValuePath.isEmpty else {
            return 1
        }
        return effectiveContext?.getDouble(stepValuePath) ?? 1
    }
    
    open func updateStepValue() {
        guard !stepValuePath.isEmpty else {
            return
        }
        control?.stepValue = getStepValue()
    }
    
}
