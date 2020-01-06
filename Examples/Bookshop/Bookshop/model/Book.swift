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

@objc(Book)
class Book: ModelEntity, Codable {
    
    var id: String!
    var name: String = ""
    var date: Date = Date()
    var marked: Bool = false
    var icon: ModelImage?
    var authors: [ModelRef] = []
    var author: ModelRef = ModelRef()
    var comment: String? = ""
    var type: String? = "0"
    var genre: ModelRef = ModelRef()
    var price: Float = 0
    var copies: Int = 0
    var dates: [BookDate] = []

}

@objc(BookDate)
class BookDate: ModelEntity, Codable {
    
    var date: Date = Date() {
        didSet {
            adjust()
        }
    }
    
    override func managed(_ context: Any? = nil) {
        let lastDate = (parent as? Book)?.dates.last?.date ?? Date()
        date = Calendar.current.date(byAdding: .day, value: 1, to: lastDate) ?? Date()
    }
    
    func adjust() {
        guard
            let book = parent as? Book,
            let index = book.dates.firstIndex(where: { (bookDate) -> Bool in
                return bookDate == self
            }) else {
            return
        }
        for i in index+1..<book.dates.count {
            book.dates[i].date = Calendar.current.date(byAdding: .day, value: i-index, to: date) ?? book.dates[i].date
        }
    }
}

extension Book {
    
    var formatMarked: String {
        return marked ? "marked".localized : "not marked"
    }
    
    func setAsMarked() {
        marked = true
    }
    
    func activate() {
        let alert = UIAlertController(title: "Book".localized, message: "Activated".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized, style: .cancel))
        UIViewController.owner?.present(alert, animated: true)
    }
    
    func setMarkedWithPrompt(_ param: Any? = nil) {
        let alert = UIAlertController(title: "Set As Marked".localized, message: "Set Book as Marked".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: { (action : UIAlertAction) in
            self.setAsMarked()
            (param as? ModelCompletion)?(true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel))
        UIViewController.owner?.present(alert, animated: true)
    }
    
    func showDetails() {
        let alert = UIAlertController(title: "Book Details".localized, message: "Show Book Details".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized, style: .cancel))
        UIViewController.owner?.present(alert, animated: true)
    }
    
    func openCatalog() {
        let alert = UIAlertController(title: "Catalog".localized, message: "Catalog Content".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized, style: .cancel))
        UIViewController.owner?.present(alert, animated: true)
    }
    
}

extension Book {
    
    override func managed(_ context: Any? = nil) {
        assign(path: "icon", entity: ModelImage(image: UIImage(named: "book"), format: .png, scale: 2, template: true))
    }
    
    var authorRefs: [Author] {
        return authors.map({ $0.ref as! Author })
    }
    
    var authorRef: Author? {
        return author.ref as? Author
    }
    
}
