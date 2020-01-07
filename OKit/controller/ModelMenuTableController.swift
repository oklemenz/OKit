//
//  ModelMenuTableController.swift
//  OKit
//
//  Created by Oliver Klemenz on 28.03.19.
//  Copyright © 2020 Oliver Klemenz. All rights reserved.
//

import Foundation
import UIKit

@objc
@objcMembers
open class ModelMenuTableController: ModelListTableController {
    
    @IBInspectable open var storyboardName: String = "Main"
    @IBInspectable open var identifier: String = ""
    @IBInspectable open var rowIdentifier: String = ""
    @IBInspectable open var hideMenu: Bool = true
    
    override open func onAccessoryTap(indexPath: IndexPath) {
        let entity = getEntity(indexPath)
        navigateToTarget(context: entity, storyboardName: storyboardName, identifier: rowIdentifier)
    }
    
    @IBAction open func navigateToHome(sender: Any?) {
        navigateToHome()
    }
    
    @IBAction open func navigateToTarget(sender: AnyObject?) {
        let identifier = sender?.value(forKey: "identifier") as? String ?? self.identifier
        navigateToTarget(context: effectiveContext, storyboardName: storyboardName, identifier: identifier)
    }
    
    open func navigateToHome() {
        if let controller = UIApplication.instance?.navigateToHome() {
            controller.resetContext()
        }
        if hideMenu {
            UIApplication.instance?.slideMenuOut()
        }
    }
    
    open func navigateToTarget(context: ModelEntity?, storyboardName: String?, identifier: String) {
        if !identifier.isEmpty {
            if let controller = UIApplication.instance?.navigateTo(storyboardName: storyboardName, identifier: identifier) {
                controller.context(context, owner: self)
            }
            if hideMenu {
                UIApplication.instance?.slideMenuOut()
            }
        } else {
            navigateToHome()
        }
    }
    
}
