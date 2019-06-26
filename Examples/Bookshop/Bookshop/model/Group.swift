//
//  AppDelegate.swift
//  Bookshop
//
//  Created by Klemenz, Oliver on 25.06.19.
//  Copyright © 2019 Klemenz, Oliver. All rights reserved.
//

import Foundation
import OKit

@objc(Group)
class Group: ModelEntity, Codable {
    
    var id: String!
    var name: String = "<New Group>"
    var status: String = "open"
    var color: String = "#0000FF"
    var authors: [Author] = []

}
