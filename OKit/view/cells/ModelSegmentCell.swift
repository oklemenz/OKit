//
//  ModelSegmentCell.swift
//  OKit
//
//  Created by Oliver Klemenz on 30.04.19.
//  Copyright © 2020 Oliver Klemenz. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
open class ModelSegmentCell: ModelEditCell {

    @IBOutlet open var control: UISegmentedControl?
    
    @IBInspectable open var segmentsPath: String = "" {
        didSet {
            updateSegments()
        }
    }
    @IBInspectable open var selectIndexPath: String = "" {
        didSet {
            updateSelectIndex()
        }
    }

    @IBInspectable open var width: String = "#200" {
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
        control = control ?? UISegmentedControl()
        
        updateFrame()
        updateSegments()
        
        accessoryView = control
        editingAccessoryView = control
        control?.addTarget(self, action: #selector(setSelectIndex), for: .valueChanged)
    }
    
    override open func updateEdit() {
        super.updateEdit()
        control?.isEnabled = effectiveEdit
    }
    
    override open func update() {
        super.update()
        updateFrame()
        updateSegments()
        updateSelectIndex()
    }

    override open func updateControlInDisplay() {
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
        control?.frame = CGRect(x: 0, y: 0, width: widthValue, height: 28)
    }
    
    // MARK: - segments
    open func updateSegments() {
        guard !segmentsPath.isEmpty else {
            return
        }
        control?.removeAllSegments()
        for segment in segmentsPath.multiParts {
            control?.insertSegment(withTitle: effectiveContext?.getString(segment) ?? "", at: control?.numberOfSegments ?? 0, animated: false)
        }
    }

    // MARK: - selectedIndex
    @objc
    open func setSelectIndex() {
        guard !selectIndexPath.isEmpty else {
            return
        }
        effectiveContext?.set(selectIndexPath, control?.selectedSegmentIndex ?? 0)
        updateTextValue()
    }
    
    open func getSelectIndex() -> Int {
        guard !selectIndexPath.isEmpty else {
            return 0
        }
        return effectiveContext?.getInt(selectIndexPath) ?? 0
    }
    
    open func updateSelectIndex() {
        guard !selectIndexPath.isEmpty else {
            return
        }
        control?.selectedSegmentIndex = getSelectIndex()
    }
    
}
