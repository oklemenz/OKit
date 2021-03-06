//
//  ModelHttp.swift
//  OKit
//
//  Created by Oliver Klemenz on 13.03.19.
//  Copyright © 2020 Oliver Klemenz. All rights reserved.
//


import Foundation

open class ModelHttp: Model {

    override open class var target: URL {
        return URL(string: Bundle.main.infoDictionary?["OKitModelEndpointUrl"] as? String ?? "")!
    }
    
    override open class func read(url: URL) throws -> Data? {
        return try Data.readHttp(url: ModelHttp.target.path(url))
    }
    
    override open class func write(url: URL, data: Data) throws {
        try data.writeHttp(url: ModelHttp.target.path(url))
    }
    
    override open class func delete(url: URL) throws {
        try Data.deleteHttp(url: ModelHttp.target.path(url))
    }
}
