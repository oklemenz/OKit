//
//  ModelTableCell.swift
//  ModelBasedApp
//
//  Created by Klemenz, Oliver on 01.03.19.
//  Copyright © 2019 Klemenz, Oliver. All rights reserved.
//

import Foundation
import UIKit

@objc
@objcMembers
open class ModelTableCell: UITableViewCell {

    var internalContext: ModelEntity?
    @IBInspectable open var contextPath: String = "" {
        didSet {
            update()
        }
    }
    @IBInspectable open var path: String = ""
    @IBInspectable open var detailPath: String = ""
    @IBInspectable open var imagePath: String = ""
    @IBInspectable open var ribbonColor: String = ""
    @IBInspectable open var editPath: String = ""
    @IBInspectable open var editDetailPath: String = ""
    @IBInspectable open var editImagePath: String = ""
    @IBInspectable open var editRibbonColor: String = ""
    @IBInspectable open var accyPath: String = ""
    @IBInspectable open var accyIcon: String = ""
    @IBInspectable open var accyText: String = ""
    @IBInspectable open var accyTap: String = ""
    @IBInspectable open var accyShow: String = "#true"
    @IBInspectable open var accyEnabled: String = "#true"
    @IBInspectable open var accyEditPath: String = ""
    @IBInspectable open var accyEditIcon: String = ""
    @IBInspectable open var accyEditText: String = ""
    @IBInspectable open var accyEditTap: String = ""
    @IBInspectable open var accyEditShow: String = "#true"
    @IBInspectable open var accyEditEnabled: String = "#true"
    @IBInspectable open var heightDisplay: String = ""
    @IBInspectable open var heightEdit: String = ""
    @IBInspectable open var heightSelect: String = ""
    @IBInspectable open var showDisplay: String = "#true"
    @IBInspectable open var showEdit: String = "#true"
    @IBInspectable open var selectNextRow: String = ""
    @IBInspectable open var selectNextAccent: String = "#true"
    
    open var selectActiveProxy: Bool = false {
        didSet {
            if isEditing, effectiveContext?.getBool(selectNextAccent) == true {
                if let label = detailTextLabel ?? textLabel {
                    if selectActiveProxy {
                        if let color = theme?.tintColor {
                            label.textColor = color
                        }
                    } else {
                        if let color = theme?.textColor {
                            label.textColor = color
                        }
                    }
                }
            }
        }
    }
    
    var indexPath: IndexPath? = nil
    
    lazy var ribbonView: UIView = {
        let ribbonView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 7.0, height: self.frame.size.height))
        ribbonView.autoresizingMask = [.flexibleHeight, .flexibleRightMargin]
        return ribbonView
    }()
    
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    open override func awakeFromNib() {
        setup()
    }

    open func setup() {
    }
}

extension ModelTableCell {
    
    override open func update() {
        updateTextValue()
        updateDetailTextValue()
        updateImageValue()
        updateRibbonColor()
        updateAccessory()
    }
    
    open func updateTextValue() {
        if !path.isEmpty || !editPath.isEmpty {
            if !editPath.isEmpty && isEditing {
                textValue = effectiveContext?.getStringAll(editPath)
            } else if !path.isEmpty {
                textValue = effectiveContext?.getStringAll(path)
            } else {
                textValue = ""
            }
        }
    }

    open func updateDetailTextValue() {
        if !detailPath.isEmpty || !editDetailPath.isEmpty {
            if !editDetailPath.isEmpty && isEditing {
                detailTextValue = effectiveContext?.getStringAll(editDetailPath)
            } else if !detailPath.isEmpty {
                detailTextValue = effectiveContext?.getStringAll(detailPath)
            } else {
                detailTextValue = ""
            }
        }
    }
    
    open func updateImageValue() {
        if !imagePath.isEmpty || !editImagePath.isEmpty {
            if !editImagePath.isEmpty && isEditing {
                imageValue = effectiveContext?.getImage(editImagePath)
            } else if !imagePath.isEmpty {
                imageValue = effectiveContext?.getImage(imagePath)
            }  else {
                imageValue = nil
            }
        }
    }
    
    open func updateRibbonColor() {
        if !ribbonColor.isEmpty || !editRibbonColor.isEmpty {
            if !editRibbonColor.isEmpty && isEditing {
                ribbonColorValue = effectiveContext?.getString(editRibbonColor)
                contentView.addSubview(ribbonView)
            } else if !ribbonColor.isEmpty {
                ribbonColorValue = effectiveContext?.getString(ribbonColor)
                contentView.addSubview(ribbonView)
            } else {
                ribbonView.removeFromSuperview()
            }
        } else {
            ribbonView.removeFromSuperview()
        }
    }
    
    open func updateAccessory() {
        if !accyPath.isEmpty {
            if let accyValue = effectiveContext?.get(accyPath) as? AccessoryType {
                self.accessoryType = accyValue
            } else if let accyValue = effectiveContext?.getInt(accyPath) {
                self.accessoryType = AccessoryType(rawValue: accyValue) ?? .none
            } else {
                self.accessoryType = .none
            }
        }
        if !accyEditPath.isEmpty {
            if let accyValue = effectiveContext?.get(accyPath) as? AccessoryType {
                self.editingAccessoryType = accyValue
            } else if let accyValue = effectiveContext?.getInt(accyPath) {
                self.editingAccessoryType = AccessoryType(rawValue: accyValue) ?? .none
            } else {
                self.editingAccessoryType = .none
            }
        }
    }
    
    open var textValue: Any? {
        get {
            return textLabel?.attributedText ?? textLabel?.text
        }
        set {
            if let attributedText = newValue as? NSAttributedString {
                textLabel?.attributedText = attributedText
            } else if let text = newValue as? String {
                textLabel?.text = text
            } else if let value = newValue {
                textLabel?.text = "\(value)"
            } else {
                textLabel?.text = ""
            }
        }
    }
    
    open var detailTextValue: Any? {
        get {
            return detailTextLabel?.attributedText ?? detailTextLabel?.text
        }
        set {
            if let attributedText = newValue as? NSAttributedString {
                detailTextLabel?.attributedText = attributedText
            } else if let text = newValue as? String {
                detailTextLabel?.text = text
            } else if let value = newValue {
                detailTextLabel?.text = "\(value)"
            } else {
                detailTextLabel?.text = ""
            }
        }
    }
    
    open var imageValue: Any? {
        get {
            return imageView?.image
        }
        set {
            imageView?.image = newValue as? UIImage
        }
    }
    
    open var ribbonColorValue: Any? {
        get {
            return ribbonView.backgroundColor
        }
        set {
            if let color = newValue as? UIColor {
                ribbonView.backgroundColor = color
            } else if let color = newValue as? String {
                ribbonView.backgroundColor = UIColor(hexColor: color)
            } else {
                ribbonView.backgroundColor = nil
            }
        }
    }
    
    override open func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if !ribbonColor.isEmpty {
            ribbonColorValue = effectiveContext?.getString(ribbonColor)
        }
    }
    
    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: true)
        if !ribbonColor.isEmpty {
            ribbonColorValue = effectiveContext?.getString(ribbonColor)
        }
    }
    
    override open func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
    }
    
}
