//
//  UIButton+Extension.swift
//  Swift Reuse Code
//
//  Created by Oliver Klemenz on 04.05.14.
//
//
import Foundation
import UIKit

extension UIButton {
    class func createCustomButton(_ imageName: String?) -> UIButton? {
        let image = UIImage(named: imageName ?? "")
        let imageLight = UIImage(named: imageName ?? "")
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0.0, y: 0.0, width: image?.size.width ?? 0.0, height: image?.size.height ?? 0.0)
        button.setBackgroundImage(image, for: .normal)
        button.setBackgroundImage(imageLight, for: .highlighted)
        button.tintColor = UIColor.black
        button.backgroundColor = UIColor.clear
        return button
    }
}
