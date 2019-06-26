//
//  Utilities.swift
//  Swift Reuse Code
//
//  Created by Oliver Klemenz on 29.12.13.
//
//

import Foundation
import UIKit

let kApplicationExtension = "tpa"
let kBrandingExtension = "tpb"
let kClassExtension = "tpc.zip"
let kPDFExtension = "pdf"
let kCSVExtension = "csv"
let kXLSExtension = "xls"
let kJPGExtension = "jpg"
let kZIPExtension = "zip"

class Utilities: NSObject {

    class func formatSeconds(_ seconds: Int) -> String? {
        let m: Int = (seconds / 60) % 60
        let s: Int = seconds % 60
        return String(format: "%02tu:%02tu", m, s)
    }

    class func formatSecondsText(_ seconds: Int) -> String? {
        let m: Int = (seconds / 60) % 60
        let s: Int = seconds % 60
        var formatted = ""
        if m > 0 {
            formatted = formatted + String(format: "%tu %@", m, "min".localized)
        }
        formatted = formatted + String(format: "%tu %@", s, "sec".localized)
        return formatted
    }

    class func formatFileSize(_ fileSize: Int64) -> String? {
        return ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
    }

    class func createUUID() -> String? {
        let uuid = CFUUIDCreate(kCFAllocatorDefault)
        let uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuid) as String?
        return uuidString
    }

    class func nameInitials(_ name: String?) -> String? {
        let nameParts = name?.components(separatedBy: " ")
        var parts: [String] = []
        for namePart in nameParts ?? [] {
            if !(namePart.trimmingCharacters(in: CharacterSet.whitespaces) == "") {
                parts.append(namePart)
            }
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

    class func calendar() -> Calendar? {
        return Calendar.current
    }

}

extension String {
    
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
}

let kDataExtension = "data"
let kCryptExtension = "crypt"

let kDataFolder = "Data"
let kGeneratedFolder = "Generated"
let kExportFolder = "Export"
let kBackupFolder = "Backup"
