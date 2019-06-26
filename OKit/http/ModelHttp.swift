//
//  ModelHttp.swift
//  OKit
//
//  Created by Klemenz, Oliver on 13.03.19.
//  Copyright © 2019 Klemenz, Oliver. All rights reserved.
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
