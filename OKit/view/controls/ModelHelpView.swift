//
//  ModelHelpView.swift
//  ModelBasedApp
//
//  Created by Klemenz, Oliver on 12.03.19.
//  Copyright © 2019 Klemenz, Oliver. All rights reserved.
//

import Foundation
import UIKit

@objc
open class ModelHelpView : ModelView, UIGestureRecognizerDelegate {
    
    internal static var helpActive: Bool = false
    
    private var owner: UIViewController?

    override open func update() {
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        isUserInteractionEnabled = true
        backgroundColor = .clear
        let background = UIView(frame: self.frame)
        background.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        background.backgroundColor = .black
        background.alpha = 0.70
        insertSubview(background, at: 0)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(gesture:)))
        tapGesture.delegate = self
        addGestureRecognizer(tapGesture)
    }
    
    open func show(owner: UIViewController) {
        if self.owner != nil {
            return
        }
        self.owner = owner
        self.owner?.view.endEditing(true)
        if let tableViewController = owner as? UITableViewController {
            tableViewController.scrollToTop()
        }
        let presenter = owner.root
        self.transform = CGAffineTransform.identity
        self.frame = CGRect(x: -1, y: -1, width: presenter.view.frame.size.width + 2, height: presenter.view.frame.size.height + 2)
        self.alpha = 0.0
        self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            presenter.view.addSubview(self)
            self.alpha = 1.0
            self.transform = CGAffineTransform.identity
        }, completion: nil)
        ModelHelpView.helpActive = true
    }
    
    @objc
    open func didTap(gesture: UIGestureRecognizer) {
        hide()
    }
    
    open func hide() {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.alpha = 0.0
            self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }, completion: { (completed) in
            self.removeFromSuperview()
            self.owner = nil
            ModelHelpView.helpActive = false
        })
    }
    
}
