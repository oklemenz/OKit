//
//  ModelSettingsTableController.swift
//  ModelBasedApp
//
//  Created by Klemenz, Oliver on 05.06.19.
//  Copyright © 2019 Klemenz, Oliver. All rights reserved.
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
