//
//  ModelTextCell.swift
//  OKit
//
//  Created by Klemenz, Oliver on 03.04.19.
//  Copyright © 2019 Klemenz, Oliver. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
open class ModelTextCell: ModelEditCell {

    @IBOutlet open var control: UITextField?
    
    @IBInspectable open var textPath: String = "" {
        didSet {
            updateText()
        }
    }
    @IBInspectable open var placeholder: String = "" {
        didSet {
            updatePlaceholder()
        }
    }
    @IBInspectable open var secure: String = "#false" {
        didSet {
            updateIsSecure()
        }
    }
    
    deinit {
        control?.removeTarget(self, action: nil, for: .allEvents)
    }
        
    open override func setup() {
        super.setup()
        prepareControl(control)
        if control == nil {
            control = UITextField()
            control?.clearButtonMode = .whileEditing
            control?.autocapitalizationType = .sentences
        }
        control?.backgroundColor = .clear
        control?.borderStyle = .none
        control?.autoresizingMask = [.flexibleWidth]
        control?.addTarget(self, action: #selector(setText), for: .editingDidEnd)
        contentView.addSubview(control!)
    }
    
    override open func updateEdit() {
        super.updateEdit()
        textLabel?.isHidden = effectiveEdit
        detailTextLabel?.isHidden = effectiveEdit
        control?.font = textLabel!.font
        control?.frame = textLabel!.frame
        control?.isHidden = !effectiveEdit
        control?.isEnabled = effectiveEdit
    }
    
    override open func update() {
        super.update()
        updateText()
        updatePlaceholder()
        updateIsSecure()
    }
    
    var effectiveTextPath: String {
        return !textPath.isEmpty ? textPath : textPath
    }
    
    // MARK: - text
    @objc
    open func setText() {
        guard !effectiveTextPath.isEmpty else {
            return
        }
        effectiveContext?.set(effectiveTextPath, control?.text ?? "")
        update()
    }

    open func getText() -> String? {
        guard !effectiveTextPath.isEmpty else {
            return nil
        }
        return effectiveContext?.getString(effectiveTextPath)
    }
    
    open func updateText() {
        guard !effectiveTextPath.isEmpty else {
            return
        }
        control?.text = getText()
    }
    
    // MARK: - placeholder
    open func getPlaceholder() -> String? {
        guard !placeholder.isEmpty else {
            return nil
        }
        return effectiveContext?.getString(placeholder)
    }

    open func updatePlaceholder() {
        guard !placeholder.isEmpty else {
            return
        }
        control?.placeholder = getPlaceholder()
    }

    // MARK: - isSecure
    open func getIsSecure() -> Bool {
        guard !secure.isEmpty else {
            return false
        }
        return effectiveContext?.getBool(secure) == true
    }

    open func updateIsSecure() {
        guard !secure.isEmpty else {
            return
        }
        control?.isSecureTextEntry = getIsSecure()
    }
    
}
