//
//  ModelSettingsTableController.swift
//  OKit
//
//  Created by Oliver Klemenz on 05.06.19.
//  Copyright © 2020 Oliver Klemenz. All rights reserved.
//

import Foundation
import UIKit

@objc
@objcMembers
open class ModelSettingsTableController: ModelDetailTableController {
 
    override open func refresh(_ entity: ModelEntity, key: String? = nil, owner: UIViewController?) -> Bool {
        guard super.refresh(entity, key: key, owner: owner) else {
            return false
        }
        UIApplication.instance?.update(animated: false)
        return true
    }
}
