//
//  UIColor.swift
//  OKit
//
//  Created by Klemenz, Oliver on 27.03.19.
//  Copyright © 2020 Klemenz, Oliver. All rights reserved.
//

import Foundation
import UIKit

@objc
public extension UIColor {
    
    convenience init(hexColor: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexColor.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    var hexColor: String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format: "#%06x", rgb)
    }
    
    var isLight: Bool {
        guard let components = cgColor.components, components.count > 2 else {return false}
        let brightness = ((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000
        return (brightness > 0.5)
    }
    
    var isDark: Bool {
        return !isLight
    }
    
    var image: UIImage {
        let size = CGSize(width: 1, height: 1)
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
    
    static var tint: UIColor {
        return UIApplication.root?.view.tintColor ?? defaultTint
    }
    
    static var defaultTint: UIColor {
        return UIView().tintColor
    }
    
    static var placeholderWhite: UIColor {
        return UIColor(red: 0.78, green: 0.78, blue: 0.80, alpha: 1.0)
    }
    
    static var placeholderBlack: UIColor {
        return UIColor(red: 0.22, green: 0.22, blue: 0.20, alpha: 1.0)
    }

}
