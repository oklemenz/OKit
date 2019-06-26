//
//  UIImage+Extension.swift
//  ModelBasedApp
//
//  Created by Klemenz, Oliver on 22.03.19.
//  Copyright © 2019 Klemenz, Oliver. All rights reserved.
//

import Foundation
import UIKit

@objc
public extension UIImage {
    
    func imageWithAlpha(alpha: Float) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: .zero, blendMode: .normal, alpha: CGFloat(alpha))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
}
