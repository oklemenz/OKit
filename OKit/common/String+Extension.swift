//
//  String+Extensions.swift
//  OKit
//
//  Created by Klemenz, Oliver on 12.03.19.
//  Copyright © 2019 Klemenz, Oliver. All rights reserved.
//

import Foundation
import UIKit

@objc
public extension NSString {
    
    var initial: String {
        return (self as String).initial
    }
    
    var localized: String {
        return (self as String).localized
    }
    
    var capitalize: String {
        return (self as String).capitalize
    }
}

public extension String {
    
    var initial: String {
        return self.isEmpty ? "" : String(self.first ?? Character(""))
    }
    
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    var capitalize: String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    var searchNormalized: String {
        var searchNormalized = self.lowercased()
        searchNormalized = searchNormalized.folding(options: [.diacriticInsensitive, .widthInsensitive, .caseInsensitive], locale: Locale.current)
        searchNormalized = searchNormalized.components(separatedBy: CharacterSet.alphanumerics.inverted).joined(separator: "")
        if let regex = try? NSRegularExpression(pattern: "(.)\\1+", options: .caseInsensitive) {
            searchNormalized = regex.stringByReplacingMatches(in: searchNormalized, options: [], range: NSRange(0..<searchNormalized.count), withTemplate: "$1")
        }
        searchNormalized = searchNormalized.trimmingCharacters(in: .whitespacesAndNewlines)
        if !searchNormalized.isEmpty {
            return searchNormalized
        }
        return self.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
    
    func title(object: String, objectPlural: String? = nil, count: Int = 0) -> NSAttributedString {
        let count = String(format: count == 1 ? "%i \(object)".localized : "%i \(objectPlural ?? (object + "s"))".localized, count)
        let text = localized.title
        text.append(NSMutableAttributedString(string: "\n"))
        text.append(count.subTitle)
        return text
    }
    
    func title(name: String) -> NSAttributedString {
        let text = self.localized.title
        text.append(NSMutableAttributedString(string: "\n"))
        text.append(name.subTitle)
        return text
    }
    
    var title: NSMutableAttributedString {
        if let textColor = UIApplication.theme?.textColor {
            return NSMutableAttributedString(string: self,
                                      attributes: [NSAttributedString.Key.foregroundColor: textColor])
        }
        return NSMutableAttributedString(string: self)
    }
    
    var subTitle: NSMutableAttributedString {
        return NSMutableAttributedString(
            string: self,
            attributes: [NSAttributedString.Key.foregroundColor: UIApplication.theme?.tintColor ?? UIColor.tint,
                         NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12.0)])
    }
    
    var nameInitials: String? {
        var parts = components(separatedBy: " ").filter { (part) -> Bool in
            return part.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != ""
        }
        if parts.count >= 2 {
            let firstInitial = parts[0].count > 0 ? parts[0].first : nil
            let lastInitial = parts[parts.count - 1].count > 0 ? parts[parts.count - 1].first : nil
            if firstInitial != nil && lastInitial != nil {
                return "\(firstInitial?.uppercased() ?? "")\(lastInitial?.uppercased() ?? "")"
            }
        } else if parts.count == 1 {
            let firstInitial = parts[0].count > 0 ? parts[0].first : nil
            return firstInitial?.uppercased()
        }
        return nil
    }
    
    static func formatSeconds(_ seconds: Int) -> String? {
        let m: Int = (seconds / 60) % 60
        let s: Int = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
    
    static func formatSecondsText(_ seconds: Int) -> String? {
        let m: Int = (seconds / 60) % 60
        let s: Int = seconds % 60
        var formatted = ""
        if m > 0 {
            formatted = "\(m) \("min.".localized)"
        }
        formatted =  formatted + " \(s) \("sec.".localized)"
        return formatted.trimmingCharacters(in: .whitespaces)
    }
    
    static func formatFileSize(_ fileSize: NSNumber?) -> String? {
        return ByteCountFormatter.string(fromByteCount: fileSize?.int64Value ?? 0, countStyle: .file)
    }
    
    var fileName: String {
        return components(separatedBy: .init(charactersIn: "/\\:\\?%*|\"<>")).joined()
    }
    
    var multiParts: [String] {
        var parts: [String] = []
        var partial: String = ""
        var bracket: Int = 0
        
        func parse(_ character: Character) {
            if character == "," && bracket == 0 {
                parts.append(partial)
                partial = ""
            } else {
                if character == "(" {
                    bracket += 1
                } else if character == ")" {
                    bracket -= 1
                }
                partial.append(character)
            }
        }
        
        forEach(parse)
        
        // Components semantics
        parts.append(partial)
        
        return parts
    }
    
    var bindingParts: [String] {
        var parts: [String] = []
        var partial: String = ""
        var bracket: Int = 0

        func parse(_ character: Character) {
            if character == "/" && bracket == 0 {
                parts.append(partial)
                partial = ""
            } else {
                if character == "(" {
                    bracket += 1
                } else if character == ")" {
                    bracket -= 1
                }
                partial.append(character)
            }
        }
        
        forEach(parse)
        
        // Split semantics
        if !partial.isEmpty {
            parts.append(partial)
        }
        
        return parts
    }
}
