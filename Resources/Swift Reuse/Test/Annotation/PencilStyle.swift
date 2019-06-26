//
//  PencilStyle.swift
//  Swift Reuse Code
//
//  Created by Oliver Klemenz on 05.08.14.
//
import Foundation
import UIKit

class PencilStyle: NSObject {
    var color: UIColor?
    var width: CGFloat = 0.0
    var alpha: CGFloat = 0.0

    convenience init(color: UIColor?, width: CGFloat, alpha: CGFloat) {
        self.init()
        self.color = color
        self.width = width
        self.alpha = alpha
    }

    func colorWithAlpha() -> UIColor? {
        let components = color?.cgColor.components
        let red: CGFloat? = components?[0]
        let green: CGFloat? = components?[1]
        let blue: CGFloat? = components?[2]
        return UIColor(red: red ?? 0.0, green: green ?? 0.0, blue: blue ?? 0.0, alpha: alpha)
    }
}
