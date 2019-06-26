//
//  UIBarButtonItem+Extension.swift
//  Swift Reuse Code
//
//  Created by Oliver Klemenz on 04.05.14.
//
//

import UIKit

extension UIBarButtonItem {
    class func createCustomTintedTopBarButtonItem(_ imageName: String?) -> UIBarButtonItem? {
        return UIBarButtonItem.createCustomTintedBarButtonItem(imageName, color: UIColor.black, disabledColor: UIColor.black)
    }

    class func createCustomTintedBottomBarButtonItem(_ imageName: String?) -> UIBarButtonItem? {
        return UIBarButtonItem.createCustomTintedBarButtonItem(imageName, color: UIColor.black, disabledColor: UIColor.black)
    }

    class func createCustomTintedBarButtonItem(_ imageName: String?, color: UIColor?, disabledColor: UIColor?) -> UIBarButtonItem? {
        let button = UIButton(type: .custom)
        let image = (UIImage(named: imageName ?? ""))?.tintImage(color)
        let imageDisabled = (UIImage(named: imageName ?? ""))?.tintImage(disabledColor)
        button.bounds = CGRect(x: 0, y: 0, width: image?.size.width ?? 0.0, height: image?.size.height ?? 0.0)
        button.setImage(image, for: .normal)
        button.setImage(imageDisabled, for: .highlighted)
        return UIBarButtonItem(customView: button)
    }
}
