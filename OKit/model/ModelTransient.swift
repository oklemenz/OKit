//
//  ModelTransient.swift
//  OKit
//
//  Created by Oliver Klemenz on 15.03.19.
//  Copyright © 2020 Oliver Klemenz. All rights reserved.
//

import Foundation

@objc
open class ModelTransient: Model {
    
    override class open func read(url: URL) throws -> Data? {
        return nil
    }
    
    override class open func write(url: URL, data: Data) throws {
    }
    
    override class open func delete(url: URL) throws {
    }
}
