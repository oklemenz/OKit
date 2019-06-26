//
//  ModelSliderCell.swift
//  OKit
//
//  Created by Klemenz, Oliver on 02.05.19.
//  Copyright © 2019 Klemenz, Oliver. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
open class ModelSliderCell: ModelEditCell {
    
    @IBOutlet open var control: UISlider?
    
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
    @IBInspectable open var maxValuePath: String = "#1" {
        didSet {
            updateMaxValue()
        }
    }
    @IBInspectable open var minImagePath: String = "" {
        didSet {
            updateMinImage()
        }
    }
    @IBInspectable open var maxImagePath: String = "" {
        didSet {
            updateMaxImage()
        }
    }
    
    @IBInspectable open var width: String = "#150" {
        didSet {
            updateFrame()
        }
    }
    
    deinit {
        control?.removeTarget(self, action: nil, for: .allEvents)
    }
    
    open override func setup() {
        super.setup()
        prepareControl(control)
        control = control ?? UISlider()
        updateFrame()
        control?.isContinuous = true
        accessoryView = control
        editingAccessoryView = control
        control?.addTarget(self, action: #selector(setSliderValue), for: .touchUpInside)
        control?.addTarget(self, action: #selector(setSliderValue), for: .touchUpOutside)
        control?.addTarget(self, action: #selector(setSliderValue), for: .touchCancel)
        control?.addTarget(self, action: #selector(refreshSliderValue), for: .valueChanged)
    }
    
    override open func updateEdit() {
        super.updateEdit()
        control?.isEnabled = effectiveEdit
    }
    
    override open func update() {
        super.update()
        updateFrame()
        updateValue()
        updateMinValue()
        updateMaxValue()
    }
    
    override open func updateControlInDisplay() {
        super.updateControlInDisplay()
        accessoryView = control
        if !controlInDisplay.isEmpty && effectiveContext?.getBool(controlInDisplay) == false {
            accessoryView = nil
        }
    }
    
    // MARK: - frame
    open func updateFrame() {
        guard !width.isEmpty else {
            return
        }
        let widthValue = CGFloat((!width.isEmpty ? effectiveContext?.getFloat(width) : nil) ?? 200)
        control?.frame = CGRect(x: 0, y: 0, width: widthValue, height: control?.bounds.size.height ?? 0)
    }
    
    // MARK: - value
    @objc
    open func setValue() {
        guard !valuePath.isEmpty else {
            return
        }
        effectiveContext?.set(valuePath, control?.value ?? getMinValue())
    }

    @objc
    open func setSliderValue() {
        setValue()
    }
    
    @objc
    open func refreshSliderValue() {
        effectiveContext?.set(valuePath, control?.value ?? getMinValue(), suppressInvalidate: true)
        updateTextValue()
    }
    
    open func getValue() -> Float {
        guard !valuePath.isEmpty else {
            return 0
        }
        return effectiveContext?.getFloat(valuePath) ?? getMinValue()
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
    
    open func getMinValue() -> Float {
        guard !minValuePath.isEmpty else {
            return 0
        }
        return effectiveContext?.getFloat(minValuePath) ?? 0
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
        effectiveContext?.set(maxValuePath, control?.maximumValue ?? 1)
    }
    
    open func getMaxValue() -> Float {
        guard !maxValuePath.isEmpty else {
            return 0
        }
        return effectiveContext?.getFloat(maxValuePath) ?? 0
    }
    
    open func updateMaxValue() {
        guard !maxValuePath.isEmpty else {
            return
        }
        control?.maximumValue = getMaxValue()
    }
    
    // MARK: - min image
    @objc
    open func setMinImage() {
        guard !minImagePath.isEmpty else {
            return
        }
        effectiveContext?.set(minImagePath, control?.minimumValueImage)
    }
    
    open func getMinImage() -> UIImage? {
        guard !minImagePath.isEmpty else {
            return nil
        }
        return effectiveContext?.getImage(minImagePath)
    }
    
    open func updateMinImage() {
        guard !minImagePath.isEmpty else {
            return
        }
        control?.minimumValueImage = getMinImage()
    }
    
    // MARK: - max value
    @objc
    open func setMaxImage() {
        guard !maxImagePath.isEmpty else {
            return
        }
        effectiveContext?.set(maxImagePath, control?.maximumValueImage)
    }
    
    open func getMaxImage() -> UIImage? {
        guard !maxImagePath.isEmpty else {
            return nil
        }
        return effectiveContext?.getImage(maxImagePath)
    }
    
    open func updateMaxImage() {
        guard !maxImagePath.isEmpty else {
            return
        }
        control?.maximumValueImage = getMaxImage()
    }
}
