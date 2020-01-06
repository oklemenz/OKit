//
//  AppDelegate.swift
//  Bookshop
//
//  Created by Klemenz, Oliver on 25.06.19.
//  Copyright © 2020 Klemenz, Oliver. All rights reserved.
//

import Foundation
import OKit
import UIKit

@objc(Shop)
class Shop: ModelEncrypted, Codable {

    var id: String!
    var books: [Book] = []
    var genres: [Genre] = {
        return [
            Genre(code: "FANTASY", name: "Fantasy".localized),
            Genre(code: "SCIENCE_FICTION", name: "Science Fiction".localized),
            Genre(code: "WESTERNS", name: "Westerns".localized),
            Genre(code: "ROMANCE", name: "Romance".localized),
            Genre(code: "THRILLER", name: "Thriller".localized),
            Genre(code: "MYSTERY", name: "Mystery".localized)
        ]
    }()
}

extension Shop {
    
    func openDirectory() {
        let alert = UIAlertController(title: "Directory".localized, message: "Directory Content".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized, style: .cancel))
        UIViewController.owner?.present(alert, animated: true)
    }
}
