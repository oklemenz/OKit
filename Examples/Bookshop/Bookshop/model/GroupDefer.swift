//
//  AppDelegate.swift
//  Bookshop
//
//  Created by Klemenz, Oliver on 25.06.19.
//  Copyright © 2019 Klemenz, Oliver. All rights reserved.
//

import Foundation
import OKit

@objc(GroupDefer)
class GroupDefer: ModelPartial, Codable {
    
    var id: String!
    var name: String = "<New Group>" {
        didSet {
            group?.name = name
        }
    }
    var color: String = "#0000FF"
    
}

extension GroupDefer {
    
    var group: Group? {
        get {
            return try? retrieve(Group.self)
        }
        set {
            assign(newValue)
        }
    }
        
    override func sync(entity: ModelEntity) {
        if let group = entity as? Group {
            name = group.name
            color = group.color
        }
    }
    
    override func store() {
        try? store(group)
    }

}
