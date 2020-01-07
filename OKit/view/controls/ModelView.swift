//
//  ModelView.swift
//  OKit
//
//  Created by Oliver Klemenz on 20.03.19.
//  Copyright © 2020 Oliver Klemenz. All rights reserved.
//

import Foundation
import UIKit

@objc
@objcMembers
open class ModelView: UIView {

    internal var internalContext: ModelEntity?
    @IBInspectable open var contextPath: String = "" {
        didSet {
            update()
        }
    }
}

@objc
extension UIView: ModelContext {
    
    // MARK: - Context
    @objc
    internal var modelContext: ModelEntity? {
        get {
            return value(forKey: "internalContext") as? ModelEntity ?? superview?.modelContext ?? Model.getDefault()
        }
        set {
            setValue(newValue, forKey: "internalContext")
        }
    }
    
    open func context(_ context: ModelEntity?, owner: AnyObject?) {
        self.modelContext = context
        for child in subviews {
            child.context(context, owner: owner)
        }
        update()
    }
    
    open var effectiveContext: ModelEntity? {
        if let contextPath = value(forKey: "contextPath") as? String {
            if !contextPath.isEmpty {
                return modelContext?.resolve(contextPath)
            }
        }
        return modelContext
    }
    
    open var contexts: [ModelEntity] {
        if let contextPath = value(forKey: "contextPath") as? String {
            if !contextPath.isEmpty {
                return modelContext?.resolve(path: contextPath) ?? []
            }
        }
        return modelContext != nil ? [modelContext!] : []
    }
}

extension UIView {

    @objc
    open func update() {
    }
    
    @objc
    open func indexPath(_ indexPath: IndexPath) {
        setValue(indexPath, forKey: "indexPath")
    }
    
    open func indexPath() -> IndexPath? {
        return value(forKey: "indexPath") as? IndexPath
    }
    
    override open func setValue(_ value: Any?, forUndefinedKey key: String) {
    }
    
    override open func value(forUndefinedKey key: String) -> Any? {
        return nil
    }
    
}

extension UIView: ModelTheming {
    
    public enum SubViewType: Int {
        case topBorder = -1
        case bottomBorder = -2
    }
    
    open func applyTheme() {
        applyTheme(UIApplication.theme)
    }
    
    open func applyTheme(_ theme: ModelTheme?) {
        for child in subviews {
            child.applyTheme(theme)
        }
    }
    
    open var theme: ModelTheme? {
        return UIApplication.theme
    }
    
    open func addTopBorder(color: UIColor? = nil, margin: CGFloat = 0.0, size: CGFloat = 1.0) -> UIView {
        let border = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: size))
        border.tag = UIView.SubViewType.topBorder.rawValue
        border.backgroundColor = color
        border.translatesAutoresizingMaskIntoConstraints = false
        border.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        self.addSubview(border)
        return border
    }
    
    open func setTopBorder(color: UIColor? = nil) {
        var border = subviews.first { (view) -> Bool in
            return view.tag == UIView.SubViewType.topBorder.rawValue
        }
        if let color = color {
            border = border ?? addTopBorder()
            border?.backgroundColor = color
        } else {
            border?.removeFromSuperview()
        }
    }
    
    open func bottomBorder() -> UIView? {
        return subviews.first { (view) -> Bool in
            return view.tag == UIView.SubViewType.bottomBorder.rawValue
        } ?? subviews.first?.subviews.first { (view) -> Bool in
            return view.tag == UIView.SubViewType.bottomBorder.rawValue
        }
    }
    
    open func addBottomBorder(color: UIColor? = nil, margin: CGFloat = 0.0, size: CGFloat = 1.0) -> UIView {
        let border = UIView()
        border.tag = UIView.SubViewType.bottomBorder.rawValue
        border.backgroundColor = color
        border.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(border)
        border.addConstraint(NSLayoutConstraint(item: border,
                                                attribute: .height,
                                                relatedBy: .equal,
                                                toItem: nil,
                                                attribute: .height,
                                                multiplier: 1,
                                                constant: size))
        self.addConstraint(NSLayoutConstraint(item: border,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .bottom,
                                              multiplier: 1,
                                              constant: 1))
        self.addConstraint(NSLayoutConstraint(item: border,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: margin))
        self.addConstraint(NSLayoutConstraint(item: border,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .trailing,
                                              multiplier: 1,
                                              constant: margin))
        return border
    }
    
    open func setBottomBorder(color: UIColor? = nil) {
        var border = bottomBorder()
        if let color = color {
            border = border ?? addBottomBorder()
            border?.backgroundColor = color
        } else {
            border?.removeFromSuperview()
        }
    }
    
    open func fadeOutBottomBorder() {
        UIView.animate(withDuration: 0.2) {
            self.bottomBorder()?.alpha = 0.0
        }
    }
    
    open func fadeInBottomBorder() {
        UIView.animate(withDuration: 0.2) {
            self.bottomBorder()?.alpha = 1.0
        }
    }

}

extension UITableViewCell {
    
    override open func applyTheme(_ theme: ModelTheme?) {
        super.applyTheme(theme)
        if let theme = theme {
            if backgroundColor != nil || backgroundColor != .clear {
                backgroundColor = theme.cellColor ?? theme.backgroundColor
            }
            if let selectColor = theme.accentColor {
                selectedBackgroundView = UIView()
                selectedBackgroundView?.backgroundColor = selectColor
            } else {
                selectedBackgroundView = nil
            }            
        }
    }

}

extension UITableView {
    
    override open func context(_ context: ModelEntity?, owner: AnyObject?) {
        self.modelContext = context
        for child in subviews where !(child is UITableViewCell) {
            child.context(context, owner: owner)
        }
        update()
    }
    
    override open func applyTheme(_ theme: ModelTheme?) {
        super.applyTheme(theme)
        if let theme = theme {
            separatorColor = theme.accentColor
            if style == .grouped {
                for section in 0..<numberOfSections {
                    if let header = headerView(forSection: section) {
                        header.backgroundView?.backgroundColor = theme.groupedBackgroundColor
                    }
                    if let footer = footerView(forSection: section) {
                        footer.backgroundView?.backgroundColor = theme.groupedBackgroundColor
                    }
                }
            }
        }
    }
}

extension UILabel {
    
    override open func applyTheme(_ theme: ModelTheme?) {
        super.applyTheme(theme)
        
        guard !(superview?.superview is UITableViewHeaderFooterView) else {
            return
        }
        
        if let theme = theme {
            textColor = theme.textColor
        }
    }
}

extension UITextField {
    
    override open func applyTheme(_ theme: ModelTheme?) {
        super.applyTheme(theme)
        if let theme = theme {
            textColor = theme.textColor
            if let clearButton = value(forKey: "clearButton") as? UIButton {
                let clearImage = UIImage(named: "clear", in: Bundle(for: ModelTableCell.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                clearButton.setImage(clearImage, for: .normal)
                clearButton.tintColor = theme.textColor
            }
            attributedPlaceholder = NSAttributedString(string: placeholder ?? "", attributes: [
                    NSAttributedString.Key.foregroundColor: theme.placeholderColor as Any])
        }
    }
}

extension UIButton {
    
    override open func applyTheme(_ theme: ModelTheme?) {
    }
}

extension UISwitch {
    
    override open func applyTheme(_ theme: ModelTheme?) {
        DispatchQueue.main.async {
            if let theme = theme {
                self.onTintColor = theme.activeColor
            }
        }
    }
}

extension UIDatePicker {
    
    override open func applyTheme(_ theme: ModelTheme?) {
        super.applyTheme(theme)
        if let theme = theme {
            setValue(theme.textColor, forKey: "textColor")
            setValue(false, forKey: "highlightsToday")
        }
    }
}

extension UIPickerView {
    
    override open func applyTheme(_ theme: ModelTheme?) {
        super.applyTheme(theme)
        if let theme = theme {
            setValue(theme.textColor, forKey: "textColor")
        }
    }
}

extension UITabBar {
    
    override open func applyTheme(_ theme: ModelTheme?) {
    }
}
