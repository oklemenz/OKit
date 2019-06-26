//  Converted to Swift 5 by Swiftify v5.0.29819 - https://objectivec2swift.com/
//
//  UIColor+Extension.swift
//  TeacherPlanner
//
//  Created by Oliver on 12.01.14.
//
//

import Foundation
import UIKit

extension UIColor {
    convenience init?(hexString: String?) {
        let colorString = hexString?.replacingOccurrences(of: "#", with: "").uppercased()
        var alpha: CGFloat
        var red: CGFloat
        var blue: CGFloat
        var green: CGFloat
        switch (colorString?.count ?? 0) {
            case 3 /* #RGB */:
                alpha = 1.0
                red = self.colorComponent(from: colorString, start: 0, length: 1)
                green = self.colorComponent(from: colorString, start: 1, length: 1)
                blue = self.colorComponent(from: colorString, start: 2, length: 1)
            case 4 /* #ARGB */:
                alpha = self.colorComponent(from: colorString, start: 0, length: 1)
                red = self.colorComponent(from: colorString, start: 1, length: 1)
                green = self.colorComponent(from: colorString, start: 2, length: 1)
                blue = self.colorComponent(from: colorString, start: 3, length: 1)
            case 6 /* #RRGGBB */:
                alpha = 1.0
                red = self.colorComponent(from: colorString, start: 0, length: 2)
                green = self.colorComponent(from: colorString, start: 2, length: 2)
                blue = self.colorComponent(from: colorString, start: 4, length: 2)
            case 8 /* #AARRGGBB */:
                alpha = self.colorComponent(from: colorString, start: 0, length: 2)
                red = self.colorComponent(from: colorString, start: 2, length: 2)
                green = self.colorComponent(from: colorString, start: 4, length: 2)
                blue = self.colorComponent(from: colorString, start: 6, length: 2)
            default:
                return nil
        }
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    func blend(with color: UIColor?, alpha: CGFloat) -> UIColor? {
        alpha = min(1.0, max(0.0, alpha))
        let beta: CGFloat = 1.0 - alpha
        var r1: CGFloat
        var g1: CGFloat
        var b1: CGFloat
        var a1: CGFloat
        var r2: CGFloat
        var g2: CGFloat
        var b2: CGFloat
        var a2: CGFloat
        getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color?.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        let red: CGFloat = r1 * beta + r2 * alpha
        let green: CGFloat = g1 * beta + g2 * alpha
        let blue: CGFloat = b1 * beta + b2 * alpha
        let newAlpha: CGFloat = a1 * beta + a2 * alpha
        return UIColor(red: red, green: green, blue: blue, alpha: newAlpha)
    }

    func hexString() -> String? {
        let components = cgColor.components
        let r: CGFloat? = components?[0]
        let g: CGFloat? = components?[1]
        let b: CGFloat? = components?[2]
        let a: CGFloat? = components?[3]
        let hexString = String(format: "%02X%02X%02X%02X", Int(a * 255), Int(r * 255), Int(g * 255), Int(b * 255))
        return hexString
    }

    func lighter() -> UIColor? {
        var h: CGFloat
        var s: CGFloat
        var b: CGFloat
        var a: CGFloat
        if getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            return UIColor(hue: h, saturation: s, brightness: min(b * 1.3, 1.0), alpha: a)
        }
        return nil
    }

    func darker() -> UIColor? {
        var h: CGFloat
        var s: CGFloat
        var b: CGFloat
        var a: CGFloat
        if getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            return UIColor(hue: h, saturation: s, brightness: b * 0.75, alpha: a)
        }
        return nil
    }

    func colorIsDark() -> Bool {
        let components = cgColor.components
        let red: CGFloat? = components?[0]
        let green: CGFloat? = components?[1]
        let blue: CGFloat? = components?[2]

        let colorBrightness: CGFloat = (((red ?? 0.0) * 299) + ((green ?? 0.0) * 587) + ((blue ?? 0.0) * 114)) / 1000
        return colorBrightness < 0.75
    }

    class func colorComponent(from string: String?, start: Int, length: Int) -> CGFloat {
        let substring = (string as NSString?)?.substring(with: NSRange(location: start, length: length))
        let fullHex = length == 2 ? substring : "\(substring ?? "")\(substring ?? "")"
        var hexComponent: UInt
        (Scanner(string: fullHex ?? "")).scanHexInt32(&hexComponent)
        return Double(hexComponent) / 255.0
    }
}
