//
//  UIImage+Extension.swift
//  Swift Reuse Code
//
//  Created by Oliver Klemenz on 30.03.14.
//
//

import UIKit

extension UIImage {
    func tintImage(_ color: UIColor?) -> UIImage? {
        if color != nil {
            UIGraphicsBeginImageContextWithOptions(size, _: false, _: UIScreen.main.scale)
            let drawRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            draw(in: drawRect)
            color?.set()
            UIRectFillUsingBlendMode(drawRect, _: .sourceAtop)
            let tintedImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return tintedImage
        }
        return self
    }

    func roundImageView() -> UIImageView? {
        let imageView = UIImageView(image: self)
        imageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = size.width / 2.0
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.borderWidth = 1.0
        return imageView
    }

    func roundImageClip() -> UIImage? {
        let size: CGFloat = self.size.width < self.size.height ? self.size.width : self.size.height
        let posX: CGFloat = self.size.width < self.size.height ? 0 : -(self.size.width - self.size.height) / 2.0
        let posY: CGFloat = self.size.width < self.size.height ? -(self.size.height - self.size.width) / 2.0 : 0
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), _: false, _: 0.0)
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setAllowsAntialiasing(true)
        UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: size, height: size)).addClip()
        draw(in: CGRect(x: posX, y: posY, width: self.size.width, height: self.size.height))
        let squareImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return squareImage
    }

    func square() -> UIImage? {
        let size: CGFloat = self.size.width < self.size.height ? self.size.width : self.size.height
        let posX: CGFloat = self.size.width < self.size.height ? 0 : -(self.size.width - self.size.height) / 2.0
        let posY: CGFloat = self.size.width < self.size.height ? -(self.size.height - self.size.width) / 2.0 : 0
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), _: false, _: 0.0)
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setAllowsAntialiasing(true)
        draw(in: CGRect(x: posX, y: posY, width: self.size.width, height: self.size.height))
        let squareImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return squareImage
    }

    func resize(_ size: CGSize) -> UIImage? {
        return resize(size, scale: 0.0)
    }

    func resize(_ size: CGSize, scale: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, _: false, _: scale)
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setAllowsAntialiasing(true)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    func tintImage(with tintColor: UIColor?) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, _: false, _: 0.0)
        let context = UIGraphicsGetCurrentContext()
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context?.scaleBy(x: 1, y: -1)
        context?.translateBy(x: 0, y: -rect.size.height)
        context?.saveGState()
        context?.clip(to: rect, mask: cgImage!)
        tintColor?.set()
        context?.fill(rect)
        context?.restoreGState()
        context!.setBlendMode(CGBlendMode.multiply)
        context?.draw(cgImage!, in: rect, byTiling: false)
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    func scaledImage(_ width: CGFloat) -> UIImage? {
        let size = CGSize(width: width, height: self.size.height * width / self.size.width)
        UIGraphicsBeginImageContextWithOptions(size, _: false, _: 0)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let scaledImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }

    func blendImage(_ blendImage: UIImage?, alpha: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, _: false, _: 0)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        blendImage?.draw(in: CGRect(x: (size.width - (blendImage?.size.width ?? 0.0)) / 2.0, y: (size.height - (blendImage?.size.height ?? 0.0)) / 2.0, width: blendImage?.size.width ?? 0.0, height: blendImage?.size.height ?? 0.0), blendMode: .normal, alpha: alpha)
        let blendedImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return blendedImage
    }
}
