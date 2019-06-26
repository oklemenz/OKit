//
//  ModelTheme.swift
//  ModelBasedApp
//
//  Created by Klemenz, Oliver on 04.04.19.
//  Copyright © 2019 Klemenz, Oliver. All rights reserved.
//

import Foundation
import UIKit

@objc
public protocol ModelTheming {
    func applyTheme(_ theme: ModelTheme?)
}

@objc
open class ModelTheme: NSObject {
    
    public var name: String!
    public var statusBarStyle: UIStatusBarStyle!
    public var barStyle: UIBarStyle!
    public var backgroundColor: UIColor!
    public var textColor: UIColor!
    public var groupedBackgroundColor: UIColor?
    public var navBarColor: UIColor?
    public var navBarLineColor: UIColor?
    public var tabBarColor: UIColor?
    public var tabBarLineColor: UIColor?
    public var toolBarColor: UIColor?
    public var toolBarLineColor: UIColor?
    public var cellColor: UIColor?
    public var activeColor: UIColor?
    public var accentColor: UIColor?
    public var placeholderColor: UIColor?
    public var tintColor: UIColor?
    
    public init(
        name: String = `default`,
        statusBarStyle: UIStatusBarStyle = .`default`,
        barStyle: UIBarStyle = .`default`,
        backgroundColor: UIColor = .white,
        textColor: UIColor = .black,
        tintColor: UIColor? = .defaultTint,
        navBarColor: UIColor? = nil,
        navBarLineColor: UIColor? = nil,
        tabBarColor: UIColor? = nil,
        tabBarLineColor: UIColor? = nil,
        toolBarColor: UIColor? = nil,
        toolBarLineColor: UIColor? = nil,
        cellColor: UIColor? = .white,
        activeColor: UIColor? = nil,
        accentColor: UIColor? = nil,
        placeholderColor: UIColor? = .placeholderWhite,
        groupedBackgroundColor: UIColor? = .groupTableViewBackground) {
        super.init()
        self.name = name
        self.statusBarStyle = statusBarStyle
        self.barStyle = barStyle
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.tintColor = tintColor
        self.navBarColor = navBarColor
        self.navBarLineColor = navBarLineColor
        self.tabBarColor = tabBarColor
        self.tabBarLineColor = tabBarLineColor
        self.toolBarColor = toolBarColor
        self.toolBarLineColor = toolBarLineColor
        self.cellColor = cellColor
        self.activeColor = activeColor
        self.accentColor = accentColor
        self.placeholderColor = placeholderColor
        self.groupedBackgroundColor = groupedBackgroundColor
    }
    
    var isDark: Bool {
        return backgroundColor.isDark
    }
}

public extension ModelTheme {
    
    static let `default`: String = ""
    static let defaultTheme = ModelTheme()
    
    static let dark: String = "dark"
    static let darkTheme = ModelTheme(
        name: dark,
        statusBarStyle: .lightContent,
        barStyle: .black,
        backgroundColor: .black,
        textColor: .white,
        tintColor: .orange,
        navBarLineColor: .white,
        tabBarLineColor: .white,
        toolBarLineColor: .white,
        cellColor: .black,
        activeColor: .orange,
        accentColor: .darkGray,
        placeholderColor: .placeholderBlack,
        groupedBackgroundColor: nil
    )
}

public class ModelThemeRegistry {
    
    public static var themes: [String:ModelTheme] = [ModelTheme.default: ModelTheme.defaultTheme,
                                                     ModelTheme.dark: ModelTheme.darkTheme]
    
    public static func register(theme: ModelTheme, name: String) {
        theme.name = name
        themes[name] = theme
    }
    
    public static func get(_ name: String) -> ModelTheme? {
        return themes[name]
    }
}
