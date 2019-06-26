//
//  ModelEncryptedHttp.swift
//  OKit
//
//  Created by Klemenz, Oliver on 13.03.19.
//  Copyright © 2019 Klemenz, Oliver. All rights reserved.
//

import Foundation

open class ModelEncryptedHttp: ModelEncrypted {
    
    override open class func read(url: URL) throws -> Data? {
        if ModelEncryptionActive {
            return try Data.readEncryptedHttp(url: ModelHttp.target.path(url))
        } else {
            return try ModelHttp.read(url: url)
        }
    }
    
    override open class func write(url: URL, data: Data) throws {
        if ModelEncryptionActive {
            try data.writeEncryptedHttp(url: ModelHttp.target.path(url))
        } else {
            try ModelHttp.write(url: url, data: data)
        }
    }
    
    override open class func delete(url: URL) throws {
        if ModelEncryptionActive {
            try Data.deleteEncryptedHttp(url: ModelHttp.target.path(url))
        } else {
            try ModelHttp.delete(url: url)
        }
    }
    
}
