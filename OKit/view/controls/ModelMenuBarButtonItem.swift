//
//  ModelMenuBarButtonItem.swift
//  OKit
//
//  Created by Oliver Klemenz on 28.03.19.
//  Copyright © 2020 Oliver Klemenz. All rights reserved.
//

import Foundation
import UIKit

open class ModelMenuBarButtonItem : UIBarButtonItem {
 
    override public init() {
        super.init()
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    open func setup() {
        target = self
        action = #selector(didTap(sender:))
        if image == nil {
            image = UIImage(named: "menu", in: Bundle(for: ModelTableCell.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        }
    }
    
    @objc
    open func didTap(sender: UIBarButtonItem) {
        if let application = UIApplication.instance {
            application.slideMenu()
        }
    }
}
