//
//  AppDelegate.swift
//  Bookshop
//
//  Created by Klemenz, Oliver on 25.06.19.
//  Copyright © 2020 Klemenz, Oliver. All rights reserved.
//

import Foundation
import OKit

@objc(Genre)
class Genre: ModelEntity, Codable {
    
    var id: String!
    var name: String = ""

    public required init() {
        super.init()
    }
    
    public convenience init(code: String, name: String) {
        self.init()
        self.id = code
        self.name = name
    }
    
}
