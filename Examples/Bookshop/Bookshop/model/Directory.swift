//
//  AppDelegate.swift
//  Bookshop
//
//  Created by Klemenz, Oliver on 25.06.19.
//  Copyright © 2019 Klemenz, Oliver. All rights reserved.
//

import Foundation
import OKit

@objc(Directory)
class Directory: Model, Codable {
    
    var id: String!
    var authors: [Author] = []
    var groups: [GroupDefer] = []
    
}
