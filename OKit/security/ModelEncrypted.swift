//
//  ModelEncrypted.swift
//  OKit
//
//  Created by Oliver Klemenz on 01.03.19.
//  Copyright © 2020 Oliver Klemenz. All rights reserved.
//

import Foundation
import UIKit

open class ModelEncrypted: Model {
    
    static var ModelEncryptionActive: Bool = true
    
    override open class func read(url: URL) throws -> Data? {
        if ModelEncryptionActive {
            return try Data.readEncryptedFile(url: Model.target.path(url))
        } else {
            return try Model.read(url: url)
        }
    }
    
    override open class func write(url: URL, data: Data) throws {
        if ModelEncryptionActive {
            try data.writeEncryptedFile(url: Model.target.path(url))
        } else {
            try Model.write(url: url, data: data)
        }
    }
    
    override open class func delete(url: URL) throws {
        if ModelEncryptionActive {
            try? Data.deleteEncryptedFile(url: Model.target.path(url))
        } else {
            try? Model.delete(url: url)
        }
    }
}
