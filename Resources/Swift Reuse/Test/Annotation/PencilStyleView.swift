//
//  PencilStyleView.swift
//  Swift Reuse Code
//
//  Created by Oliver Klemenz on 05.08.14.
//
import Foundation
import UIKit
import QuartzCore

let kPencilStyleMaxWidth = 30
let kPencilStyleBorder = 5
let kPencilStyleGrid = kPencilStyleMaxWidth + 2 * kPencilStyleBorder

protocol PencilStyleViewDelegate: NSObjectProtocol {
    func didSelectPencilStyle(_ pencilStyle: PencilStyleView?)
    func didMarkPencilStyle(_ pencilStyle: PencilStyleView?)
}

class PencilStyleView: UIView {
    var pencilStyle: PencilStyle?
    weak var delegate: PencilStyleViewDelegate?

    convenience init(pencilStyle: PencilStyle?) {
        self.init(frame: CGRect(x: 0, y: 0, width: CGFloat(kPencilStyleMaxWidth), height: CGFloat(kPencilStyleMaxWidth)))
        self.pencilStyle = pencilStyle
        backgroundColor = UIColor.clear
        layer.contentsScale = UIScreen.main.scale
        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(PencilStyleView.didTap(_:)))
        addGestureRecognizer(tap)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(PencilStyleView.didLongPress(_:)))
        addGestureRecognizer(longPress)
        refresh()
    }

    func image() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(frame.size, _: false, _: 0)
        if let context = UIGraphicsGetCurrentContext() {
            layer.render(in: context)
        }
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    func icon() -> UIImage? {
        let view: UIView? = UIImageView(frame: frame)
        view?.backgroundColor = UIColor(patternImage: UIImage(named: "raster")!)
        UIGraphicsBeginImageContextWithOptions(view?.frame.size ?? CGSize.zero, _: false, _: 0)
        if let context = UIGraphicsGetCurrentContext() {
            view?.layer.render(in: context)
        }
        image()?.draw(in: frame, blendMode: .normal, alpha: 1.0)
        let icon: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return icon
    }

    func refresh() {
        alpha = pencilStyle?.alpha ?? 0.0
        setNeedsDisplay()
    }

    func position(_ row: Int, column: Int, offset: CGPoint) {
        frame = CGRect(x: offset.x + CGFloat(column * kPencilStyleGrid) + CGFloat(kPencilStyleBorder), y: offset.y + CGFloat(row * kPencilStyleGrid) + CGFloat(kPencilStyleBorder), width: bounds.size.width, height: bounds.size.height)
    }

    @objc func didTap(_ gestureRecognizer: UITapGestureRecognizer?) {
        if gestureRecognizer?.state == .ended {
            delegate?.didSelectPencilStyle(self)
        }
    }

    @objc func didLongPress(_ gestureRecognizer: UILongPressGestureRecognizer?) {
        if gestureRecognizer?.state == .began {
            delegate?.didMarkPencilStyle(self)
        }
    }

    func setPencilStyle(_ pencilStyle: PencilStyle?) {
        self.pencilStyle = pencilStyle
        refresh()
    }

    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.addEllipse(in: pencilStyleRect())
        ctx?.setFillColor((pencilStyle?.color!.cgColor)!)
        ctx?.fillPath()
    }

    func pencilStyleRect() -> CGRect {
        return CGRect(x: (CGFloat(kPencilStyleMaxWidth) - (pencilStyle?.width ?? 0.0)) / 2.0, y: (CGFloat(kPencilStyleMaxWidth) - (pencilStyle?.width ?? 0.0)) / 2.0, width: pencilStyle?.width ?? 0.0, height: pencilStyle?.width ?? 0.0)
    }
}
