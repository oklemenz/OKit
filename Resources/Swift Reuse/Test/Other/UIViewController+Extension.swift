//
//  UIViewController+Extension.swift
//  Swift Reuse Code
//
//  Created by Oliver Klemenz on 22.06.14.
//
//

import UIKit

protocol ModalViewController: class {
}

extension UIViewController {
    func embedInNavigationController() -> UINavigationController? {
        return UINavigationController(rootViewController: self)
    }
}
