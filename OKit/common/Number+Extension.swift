//
//  Number.swift
//  OKit
//
//  Created by Klemenz, Oliver on 12.05.19.
//  Copyright © 2020 Klemenz, Oliver. All rights reserved.
//

import Foundation
import UIKit

@objc
public extension NSNumber {

    func prefix(_ prefix: String) -> String {
        return " \(prefix) \(self.stringValue)"
    }
    
    func prefixLocalized(_ prefix: String) -> String {
        return "\(prefix.localized) \(self.stringValue)"
    }
    
    func prefixPlural(_ prefix: String) -> String {
        return prefixPluralLocalized(prefix)
    }
    
    func prefixPluralLocalized(_ prefix: String) -> String {
        if self == 1 {
            return "\(prefix.localized) \(self.stringValue)"
        } else {
            return "\((prefix + "s").localized) \(self.stringValue)"
        }
    }
    
    func suffix(_ suffix: String) -> String {
        return "\(self.stringValue) \(suffix)"
    }
    
    func suffixLocalized(_ suffix: String) -> String {
        return "\(self.stringValue) \(suffix.localized)"
    }
    
    func suffixPlural(_ suffix: String) -> String {
        return suffixPluralLocalized(suffix)
    }
    
    func suffixPluralLocalized(_ suffix: String) -> String {
        if self == 1 {
            return "\(self.stringValue) \(suffix.localized)"
        } else {
            return "\(self.stringValue) \((suffix + "s").localized)"
        }
    }
    
    func round2() -> NSNumber {
        return NSDecimalNumber(value: round(Double(truncating: self) * 100)).dividing(by: NSDecimalNumber(100))
    }
}
