//
//  ModelMultilineCell.swift
//  ModelBasedApp
//
//  Created by Klemenz, Oliver on 29.04.19.
//  Copyright © 2019 Klemenz, Oliver. All rights reserved.
//

import Foundation

import Foundation
import UIKit

@IBDesignable
open class ModelMultilineCell: ModelEditCell, UITextViewDelegate {
    
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
    
    @IBOutlet open var control: UITextView?
    
    open override func awakeFromNib() {
        setup()
    }
    
    open override func setup() {
        super.setup()
        prepareControl(control)
        if control == nil {
            control = UITextView()
            control?.autocapitalizationType = .none
        }
        control?.delegate = self
        control?.frame = textLabel!.frame
        control?.font = textLabel!.font
        control?.backgroundColor = .clear
        control?.textContainerInset = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 8)
        contentView.addSubview(control!)
        
        control?.translatesAutoresizingMaskIntoConstraints = false
        control?.topAnchor.constraint(equalTo: readableContentGuide.topAnchor, constant: 0).isActive = true
        control?.bottomAnchor.constraint(equalTo: readableContentGuide.bottomAnchor, constant: 0).isActive = true
        control?.leftAnchor.constraint(equalTo: readableContentGuide.leftAnchor, constant: 0).isActive = true
        control?.rightAnchor.constraint(equalTo: readableContentGuide.rightAnchor, constant: 0).isActive = true
        
        textLabel?.isHidden = true
        detailTextLabel?.isHidden = true
    }
    
    override open func updateEdit() {
        super.updateEdit()
        control?.isEditable = effectiveEdit
    }
    
    override open func update() {
        super.update()
        updateText()
    }

    // MARK: - UITextViewDelegate
    open func textViewDidBeginEditing(_ textView: UITextView) {
        updatePlaceholder(clear: true)
    }
    
    open func textViewDidEndEditing(_ textView: UITextView) {
        setText()
        updatePlaceholder()
    }
    
    // MARK: - text
    open func setText() {
        guard !textPath.isEmpty else {
            return
        }
        effectiveContext?.set(textPath, control?.text ?? "")
    }
    
    open func getText() -> String? {
        guard !textPath.isEmpty else {
            return nil
        }
        return effectiveContext?.getString(textPath)
    }
    
    open func updateText() {
        guard !textPath.isEmpty else {
            return
        }
        control?.text = getText()
        updatePlaceholder()
    }
    
    // MARK: - placeholder
    open func getPlaceholder() -> String? {
        guard !placeholder.isEmpty else {
            return nil
        }
        return effectiveContext?.getString(placeholder)
    }

    open func updatePlaceholder(clear: Bool = false) {
        guard !placeholder.isEmpty else {
            return
        }
        control?.textColor = UIApplication.theme?.textColor
        if clear && control?.text == getPlaceholder() {
           control?.text = ""
        } else if control?.text == "" {
            control?.text = getPlaceholder()
            control?.textColor = UIApplication.theme?.placeholderColor ?? UIColor.placeholderWhite
        }
    }
}
