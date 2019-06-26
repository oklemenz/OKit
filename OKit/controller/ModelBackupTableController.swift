//
//  ModelBackupController.swift
//  ModelBasedApp
//
//  Created by Klemenz, Oliver on 04.04.19.
//  Copyright © 2019 Klemenz, Oliver. All rights reserved.
//

import Foundation
import UIKit

open class Backup: NSObject {
    var name: String!
    var url: URL!
    var createdAt: Date!
    
    init(name: String, url: URL, createdAt: Date) {
        self.name = name
        self.url = url
        self.createdAt = createdAt
    }
}

@objc
@objcMembers
open class ModelBackupTableController: ModelController {
    
    internal var backups: [Backup] = []
    
    open class var target: URL {
        return URL.documents.appendingPathComponent("okit/backup")
    }
    
    override open func setup() {
        super.setup()
        handleEdit()
        handleAdd()
        handleRefresh()
        
        update()
    }
    
    open func update() {
        loadData()
    }
    
    open func loadData() {
        backups = []
        for directoryURL in ModelBackupTableController.target.subDirectories {
            let properties = directoryURL.properties
            let creationDate = properties[FileAttributeKey.modificationDate] as! Date
            backups.append(Backup(name: directoryURL.lastPathComponent, url: directoryURL, createdAt: creationDate))
        }
        backups.sort { (a, b) -> Bool in
            return a.createdAt > b.createdAt
        }
    }

    // MARK: - Core
    open func handleEdit() {
        navigationItem.rightBarButtonItems = navigationItem.rightBarButtonItems ?? []
        let index = navigationItem.rightBarButtonItems!.firstIndex(of: editButtonItem)
        if index == nil  {
            navigationItem.rightBarButtonItems!.append(editButtonItem)
        }
    }
    
    private var addBarButton: ModelBarButtonItem!
    open func handleAdd() {
        if addBarButton == nil {
            addBarButton = ModelBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddTap(_:)))
            addBarButton.managed = true
        }
        navigationItem.rightBarButtonItems = navigationItem.rightBarButtonItems ?? []
        let index = navigationItem.rightBarButtonItems!.firstIndex(of: addBarButton)
        if index == nil  {
            navigationItem.rightBarButtonItems!.insert(addBarButton, at: 0)
        }
    }
    
    // MARK: - Refresh
    open func handleRefresh() {
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = .clear
        refreshControl?.addTarget(self, action: #selector(refreshTriggered), for: .valueChanged)
    }
    
    @objc
    open func refreshTriggered(_ refreshControl: UIRefreshControl) {
        refreshControl.endRefreshing()
        update()
    }
    
    // MARK: - Table
    override open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return backups.count
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: Model.Identifier)
        if cell == nil  {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: Model.Identifier)
        }
        let backup = backups[indexPath.row]
        cell?.textLabel?.text = backup.name
        cell?.detailTextLabel?.text = backup.createdAt.formatRelativeDateTime
        return cell!
    }
    
    override open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override open func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions: [UIContextualAction] = []
        actions.append(UIContextualAction(style: .destructive, title: "Delete".localized, handler: { (action, view, completion) in
            self.onDelete(indexPath: indexPath, completion: completion)
        }))
        return UISwipeActionsConfiguration(actions: actions)
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let backup = backups[indexPath.row]
        let alertController = restoreBackupDialog(backup: backup)
        present(alertController, animated: true)
    }
    
    // MARK: - Add
    @objc
    open func onAddTap(_ barButtonItem: UIBarButtonItem) {
        let alertController = addBackupDialog()
        self.present(alertController, animated: true, completion: nil)
    }

    internal var okAlertAction: UIAlertAction?
    open func addBackupDialog() -> UIAlertController {
        let alertController = UIAlertController(title: "New Backup".localized, message: "Enter name for this Backup", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK".localized, style: .default, handler: { (action : UIAlertAction) in
            let name = alertController.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            if let backup = self.createBackup(name: name!.fileName) {
                self.add(backup: backup)
            }
        })
        alertController.addAction(okAction)
        okAlertAction = okAction
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addTextField { (textField) in
            textField.placeholder = "Name".localized
            textField.autocorrectionType = .yes
            textField.spellCheckingType = .yes
            textField.autocapitalizationType = .sentences
            textField.clearButtonMode = .always
            textField.text = Date().formatISO
            NotificationCenter.default.addObserver(self, selector: #selector(self.handleTextFieldTextDidChangeNotification), name: UITextField.textDidChangeNotification, object: textField)
        }
        alertController.view?.tintColor = view.tintColor
        return alertController
    }
    
    open func add(backup: Backup) {
        DispatchQueue.main.async {
            self.backups.insert(backup, at: 0)
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .top)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    @objc
    open func handleTextFieldTextDidChangeNotification(notification: Notification) {
        let textField = notification.object as! UITextField
        if let okAlertAction = okAlertAction {
            okAlertAction.isEnabled = !textField.text!.fileName.isEmpty
        }
    }

    // MARK: - Restore
    open func restoreBackupDialog(backup: Backup) -> UIAlertController {
        let alertController = UIAlertController(title: "Confirm Restore".localized, message: "Do you really want to restore backup?".localized, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Yes".localized, style: .default) { (action) in
            self.restoredWith(success: self.restoreBackup(backup: backup))
        })
        alertController.addAction(UIAlertAction(title: "No".localized, style: .cancel) { (action) in
        })
        return alertController
    }
    
    open func restoredWith(success: Bool) {
        if success {
            let alert = UIAlertController(title: "Backup Restored".localized, message: "Backup was successfully restored.".localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK".localized, style: .cancel) { (action) in
                self.dismiss(animated: true)
                UIApplication.instance?.resetAll()
            })
            self.present(alert, animated: true)
        } else {
            let alert = UIAlertController(title: "Backup Not Restored".localized, message: "Restoring Backup failed. Wrong Password?".localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK".localized, style: .cancel) { (action) in
            })
            self.present(alert, animated: true)
        }

    }
    
    // MARK: - Delete
    open func onDelete(indexPath: IndexPath, completion: ModelCompletion? = nil) {
        let backup = backups[indexPath.row]
        let alert = UIAlertController(title: "Confirm Deletion".localized, message: "Do you really want to delete backup?".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes".localized, style: .default) { (action) in
            if self.deleteBackup(backup) {
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                completion?(true)
            } else {
                completion?(false)
            }
        })
        alert.addAction(UIAlertAction(title: "No".localized, style: .cancel) { (action) in
            completion?(false)
        })
        present(alert, animated: true)
    }
    
    // MARK: - Backup
    open func createBackup(name: String) -> Backup? {
        do {
            let url = ModelBackupTableController.target.appendingPathComponent(name)
            try Model.target.copyFolder(to: url)
            return Backup(name: name, url: url, createdAt: Date())
        } catch {}
        return nil
    }
    
    open func deleteBackup(_ backup: Backup) -> Bool {
        do {
            try backup.url.delete()
            if let index = backups.firstIndex(of: backup) {
                backups.remove(at: index)
                return true
            }
        } catch {}
        return false
    }
    
    open func restoreBackup(backup: Backup) -> Bool {
        do {
            try Model.target.delete()
            try backup.url.copyFolder(to: Model.target)
            return true
        } catch {}
        return false
    }
    
}
