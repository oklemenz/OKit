//
//  ModelController.swift
//  OKit
//
//  Created by Klemenz, Oliver on 11.03.19.
//  Copyright © 2020 Klemenz, Oliver. All rights reserved.
//

import Foundation
import UIKit

@objc
public protocol ModelInvalidation {
    func invalidate(_ entity: ModelEntity?, key: String?)
    func refresh(_ entity: ModelEntity, key: String?, owner: UIViewController?) -> Bool
}

@objc
@objcMembers
open class ModelController: UITableViewController {
    
    open func setup() {
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.handleTheme()
    }

    override open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.applyTheme()
        cell.indexPath(indexPath)
        cell.accessoryView?.indexPath(indexPath)
        cell.editingAccessoryView?.indexPath(indexPath)
        configure(cell: cell, indexPath: indexPath)
    }
    
    override open func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard tableView.style == .plain else {
            return
        }
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = view.theme?.textColor
        }
    }
    
    open func configure(cell: UITableViewCell, indexPath: IndexPath) {
    }
    
}

extension UIViewController: ModelInvalidation {
    
    open var root: UIViewController {
        if let parent = parent {
            return parent.root
        }
        if let present = presentingViewController {
            return present.root
        }
        return self
    }
    
    open func invalidate(_ entity: ModelEntity?, key: String? = nil) {
        guard let entity = entity else {
            return
        }
        root.invalidate(entity, key: key, owner: self)
    }
    
    open func invalidate(_ entity: ModelEntity, key: String? = nil, owner: UIViewController?) {
        _ = refresh(entity, key: key, owner: owner)
        for child in children {
            child.invalidate(entity, key: key, owner: owner)
        }
        if let child = presentedViewController, self == child.presentingViewController {
            child.invalidate(entity, key: key, owner: owner)
        }
    }
    
    open func refresh(_ entity: ModelEntity, key: String? = nil, owner: UIViewController?) -> Bool {
        return false
    }
    
    open func makeOwner() {
        UIApplication.owner = self
    }

    static public var owner: UIViewController? {
        return UIApplication.owner ?? UIApplication.root
    }
    
    @objc
    open var modelContext: ModelEntity? {
        return nil
    }
}

extension UIViewController: ModelContext {
    
    @objc
    open func resetContext() {
        for child in children {
            child.resetContext()
        }
        if let child = presentedViewController, self == child.presentingViewController {
            child.resetContext()
        }
    }

    open func context(_ context: ModelEntity?, owner: AnyObject?) {
        for child in children {
            child.context(context, owner: owner)
        }
        if let child = presentedViewController, self == child.presentingViewController {
            child.context(context, owner: owner)
        }
    }
    
    @objc
    open func requestUpdate() {
        update()
        for child in children {
            child.requestUpdate()
        }
        if let child = presentedViewController, self == child.presentingViewController {
            child.requestUpdate()
        }
    }
    
    @objc
    open func update(animated: Bool = false) {
    }
}

extension UINavigationController {
    
    override open func resetContext() {
        returnToRoot()
        viewControllers.first?.resetContext()
    }
    
    override open func context(_ context: ModelEntity?, owner: AnyObject?) {
        returnToRoot()
        viewControllers.first?.context(context, owner: owner)
    }
    
    @objc
    override open func requestUpdate() {
        update()
        viewControllers.first?.update()
    }
}

extension UITabBarController {
    
    override open func resetContext() {
        for child in viewControllers ?? [] {
            child.resetContext()
        }
    }
    
    override open func context(_ context: ModelEntity?, owner: AnyObject?) {
        for child in viewControllers ?? [] {
            child.context(context, owner: owner)
        }
    }
    
    @objc
    override open func requestUpdate() {
        update()
        for child in viewControllers ?? [] {
            child.requestUpdate()
        }
    }
}

extension UIViewController: ModelBarButtonItemDelegate, ModelButtonDelegate {

    @objc
    open func didTapBarButtonItem(_ barButtonItem: ModelBarButtonItem) {
    }
    
    @objc
    open func didTapButton(_ button: ModelButton) {
    }
}

extension UIViewController {
    
    @objc
    open var isInheritingEdit: Bool {
        return false
    }
    
    open var isModal: Bool {
        let presentingIsModal = presentingViewController != nil
        let presentingIsNavigation = navigationController?.presentingViewController?.presentedViewController == navigationController
        let presentingIsTabBar = tabBarController?.presentingViewController is UITabBarController
        return presentingIsModal || presentingIsNavigation || presentingIsTabBar
    }
    
    open func close() {
        resignFirstResponder()
        if isBeingPresented || isModal {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    @IBAction open func onCloseTap() {
        close()
    }
    
    @objc
    open func returnToRoot(animated: Bool = false) {
        dismiss(animated: animated, completion: nil)
        for view in viewIfLoaded?.subviews ?? [] {
            if let helpView = view as? ModelHelpView {
                helpView.hide()
            }
        }
        for child in children {
            child.returnToRoot(animated: animated)
        }
        if let child = presentedViewController, self == child.presentingViewController {
            child.returnToRoot(animated: animated)
        }
    }

}

extension UITableViewController {
    
    open func scrollToTop() {
        if let _ = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }

}

extension UINavigationController {

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard self != UIApplication.instance?.menuController else {
            return
        }
        
        if let app = UIApplication.instance {
            interactivePopGestureRecognizer?.isEnabled = app.popGesture
        }
    }
    
    override open func returnToRoot(animated: Bool = false) {
        super.returnToRoot(animated: animated)
        popToRootViewController(animated: false)
    }

}

extension UIViewController: ModelTheming {
    
    @objc
    open func applyTheme() {
        applyTheme(UIApplication.theme)
    }
    
    open func applyTheme(_ theme: ModelTheme?) {
        view.applyTheme(theme)
        if let theme = theme {
            if view.backgroundColor != nil && view.backgroundColor != .clear {
                view.backgroundColor = theme.backgroundColor
            }
        }
        for child in children {
            child.applyTheme(theme)
        }
        if let child = presentedViewController, self == child.presentingViewController {
            child.applyTheme(theme)
        }
    }
    
    open func handleTheme() {
        let theme = UIApplication.theme
        tabBarController?.applyTheme(theme)
        navigationController?.applyTheme(theme)
        applyTheme(theme)
    }
    
}

extension UITableViewController {
    
    override open func applyTheme(_ theme: ModelTheme?) {
        super.applyTheme(theme)
        if let theme = theme {
            if view.backgroundColor != nil && view.backgroundColor != .clear {
                if tableView.style == .grouped {
                    view.backgroundColor = theme.groupedBackgroundColor ?? theme.backgroundColor
                } else {
                    view.backgroundColor = theme.backgroundColor
                }
            }
            DispatchQueue.main.async {
                if let searchBar = self.navigationItem.searchController?.searchBar {
                    searchBar.setBottomBorder(color: theme.navBarLineColor)
                    self.navigationController?.navigationBar.setBottomBorder(color: nil)
                }
            }
        }
    }
}

extension UINavigationController {
    
    override open func applyTheme(_ theme: ModelTheme?) {
        super.applyTheme(theme)
        if let theme = theme {
            navigationBar.barTintColor = theme.navBarColor
            navigationBar.barStyle = theme.barStyle
            toolbar.barTintColor = theme.toolBarColor
            toolbar.barStyle = theme.barStyle
            DispatchQueue.main.async {
                self.navigationBar.setBottomBorder(color: theme.navBarLineColor)
                self.toolbar.setTopBorder(color: theme.toolBarLineColor)
            }
        }
    }
}

extension UITabBarController {
    
    override open func applyTheme(_ theme: ModelTheme?) {
        super.applyTheme(theme)
        if let theme = theme {
            tabBar.barTintColor = theme.tabBarColor
            tabBar.barStyle = theme.barStyle
            DispatchQueue.main.async {
                self.tabBar.setTopBorder(color: theme.tabBarLineColor)
            }
        }
    }
}
