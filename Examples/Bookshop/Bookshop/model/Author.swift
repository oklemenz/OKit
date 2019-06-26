//
//  AppDelegate.swift
//  Bookshop
//
//  Created by Klemenz, Oliver on 25.06.19.
//  Copyright © 2019 Klemenz, Oliver. All rights reserved.
//

import Foundation
import OKit

@objc(Author)
class Author: ModelEntity, Codable {
    
    var id: String!
    var name: String = "<New Author>"
    
}
