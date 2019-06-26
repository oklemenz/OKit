//
//  UILabel+Extension.swift
//  Swift Reuse Code
//
//  Created by Oliver Klemenz on 05.10.14.
//
//

import UIKit

enum SlideDirection : Int {
    case leftToRight
    case rightToLeft
    case topToBottom
    case bottomToTop
}

extension UILabel {
    class func createTwoLineTitleLabel(_ title: String?, color: UIColor?) -> UILabel? {
        let font = UIFont.systemFont(ofSize: 14.0)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 2
        label.textAlignment = .center
        if let color = color {
            label.textColor = color
        }
        label.font = font
        label.updateTwoLineTitleLabel(title, color: color)
        return label
    }

    func updateTwoLineTitleLabel(_ title: String?, color: UIColor?) {
        let font = UIFont.systemFont(ofSize: 14.0)
        let boldFont = UIFont.boldSystemFont(ofSize: 15.0)
        let attrTitle = NSMutableAttributedString(string: title ?? "")
        if color != nil {
            attrTitle.addAttribute(.foregroundColor, value: color as Any, range: NSRange(location: 0, length: title?.count ?? 0))
        }
        attrTitle.addAttribute(.font, value: font, range: NSRange(location: 0, length: title?.count ?? 0))
        let firstLineLocation: Int? = (title as NSString?)?.range(of: "\n").location
        if firstLineLocation != NSNotFound {
            let firstLineRange = NSRange(location: 0, length: firstLineLocation ?? 0)
            attrTitle.addAttribute(.font, value: boldFont, range: firstLineRange)
        } else {
            attrTitle.addAttribute(.font, value: boldFont, range: NSRange(location: 0, length: title?.count ?? 0))
        }
        attributedText = attrTitle
    }

    class func createSlideLabel(_ text: String?, frame: CGRect, direction: SlideDirection) -> UILabel? {
        let label = UILabel(frame: frame)
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        if let font = UIFont(name: "HelveticaNeue-Light", size: 25) {
            label.font = font
        }
        switch direction {
            case .leftToRight:
                label.textAlignment = .left
            case .rightToLeft:
                label.textAlignment = .right
            default:
                label.textAlignment = .center
        }
        let attrText = NSMutableAttributedString(string: text ?? "")
        if (text as NSString?)?.range(of: ">").location == 0 || (text as NSString?)?.range(of: "^").location == 0 {
            attrText.addAttribute(.font, value: UIFont(name: "HelveticaNeue-Light", size: 35) as Any, range: NSRange(location: 0, length: 1))
        }
        if (text as NSString?)?.range(of: "<").location == (text?.count ?? 0) - 1 {
            attrText.addAttribute(.font, value: UIFont(name: "HelveticaNeue-Light", size: 35) as Any, range: NSRange(location: (text?.count ?? 0) - 1, length: 1))
        }
        label.slide(withText: attrText, direction: direction, duration: 2.0)
        return label
    }

    func slide(withText text: NSAttributedString?, direction: SlideDirection, duration: CFTimeInterval) {
        if text != nil {
            attributedText = text
        }

        var maskImage = ""
        var maskFrame: CGRect

        switch direction {
            case .leftToRight:
                maskImage = "mask_h"
                maskFrame = CGRect(x: -frame.size.width, y: 0.0, width: frame.size.width * 2, height: frame.size.height)
            case .rightToLeft:
                maskImage = "mask_h"
                maskFrame = CGRect(x: 0.0, y: 0.0, width: frame.size.width * 2, height: frame.size.height)
            case .topToBottom:
                maskImage = "mask_v"
                maskFrame = CGRect(x: 0.0, y: -frame.size.height, width: frame.size.width, height: frame.size.height * 2)
            case .bottomToTop:
                maskImage = "mask_v"
                maskFrame = CGRect(x: 0.0, y: 0.0, width: frame.size.width, height: frame.size.height * 2)
        }

        let maskLayer = CALayer()
        maskLayer.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.15).cgColor
        maskLayer.contents = UIImage(named: maskImage)?.cgImage
        maskLayer.contentsGravity = .center
        maskLayer.frame = maskFrame
        layer.mask = maskLayer

        addSlideAnimation(direction, duration: duration)
    }

    func addSlideAnimation(_ direction: SlideDirection, duration: CFTimeInterval) {
        var maskProperty = ""
        var maskAnimByValue: CGFloat = 0.0

        switch direction {
            case .leftToRight:
                maskProperty = "position.x"
                maskAnimByValue = frame.size.width
            case .rightToLeft:
                maskProperty = "position.x"
                maskAnimByValue = -frame.size.width
            case .topToBottom:
                maskProperty = "position.y"
                maskAnimByValue = frame.size.height
            case .bottomToTop:
                maskProperty = "position.y"
                maskAnimByValue = -frame.size.height
        }
        let maskAnim = CABasicAnimation(keyPath: maskProperty)
        maskAnim.byValue = NSNumber(value: Float(maskAnimByValue))
        maskAnim.repeatCount = Float.greatestFiniteMagnitude
        maskAnim.duration = duration
        layer.mask?.add(maskAnim, forKey: "slideAnim")
    }
}
