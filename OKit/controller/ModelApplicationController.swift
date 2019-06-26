//
//  ModelApplicationController.swift
//  OKit
//
//  Created by Klemenz, Oliver on 28.03.19.
//  Copyright © 2019 Klemenz, Oliver. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication: ModelInvalidation {
    
    static public var root: UIViewController? {
        return UIApplication.shared.keyWindow?.rootViewController
    }
    
    static public var instance: ModelApplicationContoller? {
        return ModelApplicationContoller.instance
    }
    
    static public var theme: ModelTheme? {
        return instance?.theme
    }
    
    static public var owner: UIViewController?
    
    static public func invalidate(_ entity: ModelEntity?, key: String? = nil) {
        guard let entity = entity else {
            return
        }
        UIApplication.root?.invalidate(entity, key: key, owner: UIViewController.owner)
    }
    
    open func invalidate(_ entity: ModelEntity?, key: String? = nil) {
        UIApplication.invalidate(entity, key: key)
    }
    
    open func refresh(_ entity: ModelEntity, key: String? = nil, owner: UIViewController?) -> Bool {
        return false
    }
    
}

@objc
@objcMembers
open class ModelApplicationContoller: UIViewController, UIGestureRecognizerDelegate {
    
    public static let Theme = "\(OKitNamespace).Theme"
    public static let Encryption = "\(OKitNamespace).Encryption"
    public static let Protection = "\(OKitNamespace).Protection"
    public static let ProtectionTimeout = "\(OKitNamespace).ProtectionTimeout"
    public static let ProtectionCover = "\(OKitNamespace).ProtectionCover"
    
    public static var instance: ModelApplicationContoller?
    
    public let duration: CGFloat = 0.25
    public let fade: CGFloat = 0.5
    public let shadow: CGFloat = 0.6
    public let offset: CGFloat = 60
    
    open var protectActive: Bool = true
    open var protectTimeout: Float = 5 // Minutes
    open var protectCover: Bool = true
    open var protectClearTimer: Timer?
    
    open var theme: ModelTheme?
    
    @IBInspectable open var storyboardName: String = "Main"
    @IBInspectable open var menuIdentifier: String = "menu"
    @IBInspectable open var homeIdentifier: String = "home"
    @IBInspectable open var popGesture: Bool = false
    
    @IBInspectable open var themeName: String = "" {
        didSet {
            _applyTheme(effectiveThemeName)
        }
    }
    open var effectiveThemeName: String {
        return (!themeName.isEmpty ? effectiveContext?.getString(themeName) : nil) ?? ModelTheme.default
    }
    
    @IBInspectable open var encryption: String = "#true" {
        didSet {
            _applyEncryption(effectiveEncryption)
        }
    }
    open var effectiveEncryption: Bool {
        return (!encryption.isEmpty ? effectiveContext?.getBool(encryption) : nil) ?? true
    }
    
    @IBInspectable open var protection: String = "#true" {
        didSet {
            _applyProtection(effectiveProtection)
        }
    }
    open var effectiveProtection: Bool {
        return (!protection.isEmpty ? effectiveContext?.getBool(protection) : nil) ?? true
    }
    
    @IBInspectable open var protectionTimeout: String = "#5" {
        didSet {
            _applyProtectionTimeout(effectiveProtectionTimeout)
        }
    }
    open var effectiveProtectionTimeout: Float {
        return (!protectionTimeout.isEmpty ? effectiveContext?.getFloat(protectionTimeout) : nil) ?? 5
    }
    
    @IBInspectable open var protectionCover: String = "#true" {
        didSet {
            _applyProtectionCover(effectiveProtectionCover)
        }
    }
    open var effectiveProtectionCover: Bool {
        return (!protectionCover.isEmpty ? effectiveContext?.getBool(protectionCover) : nil) ?? true
    }
    
    @IBInspectable open var protectionImage: String = "" {
        didSet {
            resetProtectionCover()
        }
    }
    @IBInspectable open var protectionText: String = "" {
        didSet {
            resetProtectionCover()
        }
    }

    // MARK: - Context
    internal var internalContext: ModelEntity?
    override open var context: ModelEntity? {
        get {
            return internalContext ?? parent?.context ?? Model.getDefault()
        }
        set {
            internalContext = newValue
            update()
        }
    }
    
    override open func resetContext() {
        self.context = nil
        menuController.resetContext()
        contentController?.resetContext()
        update()
    }
    
    override open func context(_ context: ModelEntity?, owner: AnyObject?) {
        self.context = context
        menuController.context(context, owner: owner)
        contentController?.context(context, owner: owner)
        update()
    }
    
    open var effectiveContext: ModelEntity? {
        if !contextPath.isEmpty {
            return context?.resolve(contextPath)
        }
        return context
    }
    
    // MARK: - Inspectable
    @IBInspectable open var contextPath: String = "" {
        didSet {
            update()
        }
    }
    
    private var protectBackgroundTaskIdentifier: UIBackgroundTaskIdentifier?
    private var menuEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer!
    private var menuPanGestureRecognizer: UIPanGestureRecognizer!
    private var _contentController: UIViewController?
    private var contentController: UIViewController? {
        get {
            return _contentController
        }
        set {
            guard _contentController != newValue else {
                return
            }
            if let contentController = _contentController {
                contentController.willMove(toParent: nil)
                contentController.view.removeFromSuperview()
                contentController.removeFromParent()
            }
            _contentController = newValue
            if let contentController = _contentController {
                addChild(contentController)
                view.insertSubview(contentController.view, at: 0)
                contentController.view.frame = view.frame
                contentController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                contentController.didMove(toParent: self)
                contentController.update()
            }
        }
    }
    
    private var contentCache: [String: UIViewController] = [:]
    private var contentCacheKey: String = ""
    
    private var menuVisible: Bool = false
    
    open lazy var menuContainerView: UIView = {
        let menuWidth = view.bounds.size.width - offset
        let menuContainerView = UIView(frame: CGRect(x: 0, y: 0, width: menuWidth + 3, height: view.bounds.size.height))
        menuContainerView.translatesAutoresizingMaskIntoConstraints = false
        menuContainerView.autoresizingMask = [.flexibleHeight]
        menuContainerView.clipsToBounds = true
        menuContainerView.isUserInteractionEnabled = false
        return menuContainerView
    }()
    
    open lazy var menuCoverView: UIView = {
        let menuCoverView = UIView(frame: view.bounds)
        menuCoverView.backgroundColor = .black
        menuCoverView.translatesAutoresizingMaskIntoConstraints = false
        menuCoverView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        menuCoverView.alpha = 0.0
        menuCoverView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapMenuCover(sender:)))
        menuCoverView.addGestureRecognizer(tapGesture)
        return menuCoverView
    }()
    
    open lazy var menuController: UIViewController = {
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
        let menuController = storyboard.instantiateViewController(withIdentifier: menuIdentifier)
        let menuWidth = view.bounds.size.width - offset
        menuController.view.frame = CGRect(x: -menuWidth, y: 0, width: menuWidth, height: view.bounds.size.height)
        menuController.view.layer.shadowColor = UIColor.black.cgColor
        menuController.view.layer.shadowRadius = 2.0
        menuController.view.layer.shadowOpacity = 0.0
        menuController.view.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        return menuController
    }()
    
    private var _protectCoverView: UIView?
    open var protectCoverView: UIView {
        get {
            if _protectCoverView == nil {
                let blurEffect = theme?.isDark == true ? UIBlurEffect(style: .dark) : UIBlurEffect(style: .prominent)
                let protectCover = UIVisualEffectView(effect: blurEffect)
                let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
                let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
                vibrancyView.translatesAutoresizingMaskIntoConstraints = false
                vibrancyView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                let stack = UIStackView()
                stack.axis = .vertical
                stack.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
                stack.frame = CGRect(x: 0, y: 0, width: 185, height: 185)
                stack.center = CGPoint(x: vibrancyView.center.x, y: vibrancyView.center.y - 3)
                if let protectionImage = effectiveContext?.getImage(protectionImage) {
                    let image = UIImageView(image: protectionImage)
                    stack.addArrangedSubview(image)
                }
                if let protectionText = effectiveContext?.getString(protectionText), !protectionText.isEmpty {
                    let label = UILabel()
                    label.text = protectionText
                    label.sizeToFit()
                    label.frame = CGRect(x: 0, y: 0, width: stack.frame.size.width, height: label.frame.size.height)
                    label.textAlignment = .center
                    stack.addArrangedSubview(label)
                }
                vibrancyView.contentView.addSubview(stack)
                protectCover.contentView.addSubview(vibrancyView)
                protectCover.translatesAutoresizingMaskIntoConstraints = false
                protectCover.frame = view.bounds
                protectCover.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                protectCover.isUserInteractionEnabled = true
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapProtectCover(sender:)))
                protectCover.addGestureRecognizer(tapGesture)
                _protectCoverView = protectCover
            }
            return _protectCoverView!
        }
    }
    
    open func resetProtectionCover() {
        _protectCoverView?.removeFromSuperview()
        _protectCoverView = nil
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        ModelApplicationContoller.instance = self
    }
    
    // MARK: - Setup
    override open func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Protection
        if ModelSecureStore.initialized() && protectCover {
            showProtectionCover(false)
        }
    }

    open func setup() {
        // Configuration
        _applyTheme(currentThemeName ?? effectiveThemeName)
        _applyEncryption(currentEncryption ?? effectiveEncryption)
        _applyProtection(currentProtection ?? effectiveProtection)
        _applyProtectionTimeout(currentProtectionTimeout ?? effectiveProtectionTimeout)
        _applyProtectionCover(currentProtectionCover ?? effectiveProtectionCover)

        // Content
        _ = navigateToHome()
        
        // Menu Cover
        view.addSubview(menuCoverView)
        
        // Menu
        addChild(menuController)
        menuController.didMove(toParent: self)
        menuContainerView.addSubview(menuController.view)
        view?.addSubview(menuContainerView)
        
        // Gestures
        menuEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        menuEdgePanGestureRecognizer.edges = .left
        menuEdgePanGestureRecognizer.delegate = self
        view.addGestureRecognizer(menuEdgePanGestureRecognizer)
        menuPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        menuPanGestureRecognizer.delegate = self
        menuCoverView.addGestureRecognizer(menuPanGestureRecognizer)
    }
    
    // MARK: - Protect
    open func protect() {
        endEditing()

        guard protectActive, ModelSecureStore.initialized() else {
            return
        }
        
        if protectCover {
            showProtectionCover()
        }

        let protectImmediately = protectTimeout == 0
        if protectImmediately {
            protectData()
        } else {
            protectClearTimer = Timer(timeInterval: TimeInterval(protectTimeout * 60), target: self, selector: #selector(protectData), userInfo: nil, repeats: false)
        }
        protectBackgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask {
            self.protectClearTimer?.fire()
            if let protectBackgroundTaskIdentifier = self.protectBackgroundTaskIdentifier {
                UIApplication.shared.endBackgroundTask(protectBackgroundTaskIdentifier)
            }
            self.protectBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
        }
    }
    
    open func unprotect(completion: ModelCompletion? = nil) {
        guard protectActive else {
            return
        }
        
        if let protectBackgroundTaskIdentifier = self.protectBackgroundTaskIdentifier {
            if protectBackgroundTaskIdentifier != UIBackgroundTaskIdentifier.invalid {
                UIApplication.shared.endBackgroundTask(protectBackgroundTaskIdentifier)
                self.protectBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
                protectClearTimer?.invalidate()
                protectClearTimer = nil
            }
        }
        if (ModelSecureStore.instance.isOpen) {
            hideProtectionCover()
        } else {
            ModelSecureStore.instance.open({ (completed) in
                if completed {
                    completion?(completed)
                    UIApplication.root?.requestUpdate()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.hideProtectionCover()
                    }
                }
            })
        }
    }
    
    @objc
    open func protectData() {
        ModelSecureStore.instance.close()
    }
    
    open func showProtectionCover(_ force: Bool = true) {
        if effectiveProtectionCover && (force || !ModelSecureStore.instance.isOpen) {
            protectCoverView.isHidden = false
            window?.addSubview(protectCoverView)
        }
    }
    
    open func hideProtectionCover() {
        if ModelSecureStore.instance.isOpen {
            protectCoverView.isHidden = true
        }
    }
    
    @objc
    open func didTapProtectCover(sender: UIGestureRecognizer) {
        Model.unprotectAndSync();
    }    
    
    // MARK: - Slide Menu
    @objc
    open func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        let leftToRight = recognizer.velocity(in: view).x > -1
        switch recognizer.state {
        case .began:
            endEditing()
            UIView.animate(withDuration: TimeInterval(duration), delay: 0.0, options: .curveEaseInOut, animations: {
                self.isStatusBarHidden = true
                self.menuController.view.layer.shadowOpacity = Float(self.shadow)
            }, completion: nil)
            break
        case .changed:
            slideMenuTracked(dx: recognizer.translation(in: view).x)
            recognizer.setTranslation(CGPoint.zero, in: view)
        case .ended:
            if leftToRight {
                slideMenuIn()
            } else {
                slideMenuOut()
            }
        default:
            break
        }
    }
    
    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return !ModelHelpView.helpActive
    }
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer == menuEdgePanGestureRecognizer {
            return !menuVisible
        }
        if gestureRecognizer == menuPanGestureRecognizer {
            return menuVisible
        }
        return true
    }
    
    open func slideMenu(animated: Bool = true) {
        if menuVisible {
            slideMenuOut()
        } else {
            slideMenuIn()
        }
    }
    
    open func slideMenuIn(animated: Bool = true) {
        endEditing()
        menuVisible = true
        UIView.animate(withDuration: animated ? TimeInterval(duration) : 0.0, delay: 0.0, options: .curveEaseInOut, animations: {
            self.isStatusBarHidden = true
            self.menuCoverView.alpha = self.fade
            let frame = self.menuController.view.frame
            self.menuController.view.center.x = frame.width / 2
            self.menuController.view.layer.shadowOpacity = Float(self.shadow)
            self.menuContainerView.isUserInteractionEnabled = true
        }, completion: nil)
    }
    
    open func slideMenuOut(animated: Bool = true) {
        endEditing()
        menuVisible = false
        UIView.animate(withDuration: animated ? TimeInterval(duration) : 0.0, delay: 0.0, options: .curveEaseInOut, animations: {
            self.isStatusBarHidden = false
            self.menuCoverView.alpha = 0.0
            let frame = self.menuController.view.frame
            self.menuController.view.center.x = -frame.width / 2
            self.menuContainerView.isUserInteractionEnabled = false
        }) { (completed) in
            self.menuController.view.layer.shadowOpacity = 0.0
        }
    }
    
    open func slideMenuTracked(dx: CGFloat) {
        menuController.view.center.x = menuController.view.center.x + dx
        let frame = self.menuController.view.frame
        if menuController.view.center.x < -frame.width / 2 {
           menuController.view.center.x = -frame.width / 2
        }
        if menuController.view.center.x > frame.width / 2 {
            menuController.view.center.x = frame.width / 2
        }
        let ratio = (menuController.view.center.x + frame.width / 2) / frame.width
        self.menuCoverView.alpha = ratio * self.fade
    }

    @objc
    open func didTapMenuCover(sender: UIGestureRecognizer) {
        slideMenu()
    }
    
    open func endEditing() {
        UIApplication.shared.keyWindow?.endEditing(true)
    }
    
    // MARK: - Navigation
    open func navigateToHome() -> UIViewController? {
        contentController = navigateTo(storyboardName: storyboardName, identifier: homeIdentifier)
        return contentController
    }
    
    open func navigateTo(storyboardName: String? = nil, identifier: String) -> UIViewController? {
        let storyboardName = storyboardName ?? self.storyboardName
        let contentCacheKey = "\(storyboardName)~\(identifier)"
        if self.contentCacheKey == contentCacheKey {
            return contentController
        }
        self.contentCacheKey = contentCacheKey
        if let contentController = contentCache[contentCacheKey] {
            self.contentController = contentController
        } else {
            let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
            contentController = storyboard.instantiateViewController(withIdentifier: identifier)
            contentCache[contentCacheKey] = contentController
        }
        return contentController
    }

    // MARK: - Status Bar
    open var isStatusBarHidden: Bool = false {
        didSet{
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }

    override open var preferredStatusBarUpdateAnimation: UIStatusBarAnimation{
        return .fade
    }
    
    override open var prefersStatusBarHidden: Bool{
        return isStatusBarHidden
    }
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return theme?.statusBarStyle ?? super.preferredStatusBarStyle
    }

    // MARK: - Window
    private var _window: UIWindow?
    open func initialized(window: UIWindow?) {
        _window = window
    }
    open var window: UIWindow? {
        return UIApplication.shared.keyWindow ?? _window
    }

    // MARK: - Apply
    open func apply() {
        applyTheme()
        applyEncryption()
        applyProtection()
        applyProtectionTimeout()
        applyProtectionCover()
    }
    
    // MARK: - Theme
    override open func applyTheme() {
        let name = effectiveThemeName
        setCurrentThemeName(name)
        _applyTheme(name)
    }
    
    private func _applyTheme(_ name: String) {
        guard !(theme == nil && name == ModelTheme.default) else {
            return
        }
        self.applyTheme(ModelThemeRegistry.get(name))
    }
    
    override open func applyTheme(_ theme: ModelTheme?) {
        guard theme != nil, self.theme != theme else {
            return
        }
        self.theme = theme
        window?.tintColor = theme?.tintColor
        UISwitch.appearance().onTintColor = theme?.activeColor
        UITextField.appearance().keyboardAppearance = theme?.isDark == true ? .dark : .default
        setNeedsStatusBarAppearanceUpdate()
        menuController.view.layer.shadowColor = theme?.isDark == true ? UIColor.white.cgColor : UIColor.black.cgColor
        menuController.applyTheme(theme)
        contentController?.applyTheme(theme)
        super.applyTheme(theme)
        resetProtectionCover()
        resetContent()
    }
    
    open var currentThemeName: String? {
        return UserDefaults.standard.object(forKey: ModelApplicationContoller.Theme) as? String
    }
    
    open func setCurrentThemeName(_ name: String) {
        UserDefaults.standard.set(name, forKey: ModelApplicationContoller.Theme)
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - Encryption
    open func applyEncryption() {
        let encryption = effectiveEncryption
        setCurrentEncryption(encryption)
        _applyEncryption(encryption)
    }

    private func _applyEncryption(_ encryption: Bool) {
        if ModelEncrypted.ModelEncryptionActive != encryption {
            ModelEncrypted.ModelEncryptionActive = encryption
            Model.updateAllState()
        }
    }
    
    open var currentEncryption: Bool? {
        return UserDefaults.standard.bool(forKey: ModelApplicationContoller.Encryption)
    }
    
    open func setCurrentEncryption(_ encryption: Bool) {
        UserDefaults.standard.set(encryption, forKey: ModelApplicationContoller.Encryption)
        UserDefaults.standard.synchronize()
    }

    // MARK: - Protection
    open func applyProtection() {
        let protection = effectiveProtection
        setCurrentProtection(protection)
        _applyProtection(protection)
    }
    
    private func _applyProtection(_ protection: Bool) {
        if protectActive != protection {
            protectActive = protection
            try? ModelSecureStore.instance.setBiometrics(protection)
        }
    }
    
    open var currentProtection: Bool? {
        return UserDefaults.standard.bool(forKey: ModelApplicationContoller.Protection)
    }
    
    open func setCurrentProtection(_ protection: Bool) {
        UserDefaults.standard.set(protection, forKey: ModelApplicationContoller.Protection)
        UserDefaults.standard.synchronize()
    }

    // MARK: - Protection Timeout
    open func applyProtectionTimeout() {
        if self.protectTimeout != effectiveProtectionTimeout {
            let protectionTimeout = effectiveProtectionTimeout
            setCurrentProtectionTimeout(protectionTimeout)
            _applyProtectionTimeout(protectionTimeout)
        }
    }
    
    private func _applyProtectionTimeout(_ protectionTimeout: Float) {
        self.protectTimeout = protectionTimeout
    }
    
    open var currentProtectionTimeout: Float? {
        return UserDefaults.standard.float(forKey: ModelApplicationContoller.ProtectionTimeout)
    }
    
    open func setCurrentProtectionTimeout(_ timeout: Float) {
        UserDefaults.standard.set(timeout, forKey: ModelApplicationContoller.ProtectionTimeout)
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - Protection Cover
    open func applyProtectionCover() {
        let protectionCover = effectiveProtectionCover
        setCurrentProtectionCover(protectionCover)
        _applyProtectionCover(protectionCover)
    }
    
    private func _applyProtectionCover(_ protectionCover: Bool) {
        if protectCover != effectiveProtectionCover {
            protectCover = protectionCover
        }
    }
    
    open var currentProtectionCover: Bool? {
        return UserDefaults.standard.bool(forKey: ModelApplicationContoller.ProtectionCover)
    }
    
    open func setCurrentProtectionCover(_ protectionCover: Bool) {
        UserDefaults.standard.set(protectionCover, forKey: ModelApplicationContoller.ProtectionCover)
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - Reset
    open func resetContent() {
        contentController = nil
        contentCacheKey = ""
        contentCache.removeAll()
        _ = navigateToHome()
    }
    
    open func resetAll() {
        slideMenuOut(animated: false)
        resetContent()
        Model.sync()
        resetContext()
    }
    
    @objc
    override open func requestUpdate() {
        update()
        menuController.requestUpdate()
        contentController?.requestUpdate()
    }
    
    // MARK: - Invalidation
    override open func refresh(_ entity: ModelEntity, key: String? = nil, owner: UIViewController?) -> Bool {
        let contexts = context?.resolve(path: contextPath)
        guard contexts?.contains(entity) == true else {
            return false
        }
        update()
        apply()
        return true
    }
}
