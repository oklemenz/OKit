//
//  ModelProtectedBackupTableController.swift
//  OKit
//
//  Created by Klemenz, Oliver on 03.05.19.
//  Copyright © 2020 Klemenz, Oliver. All rights reserved.
//

import Foundation
import UIKit

@objc
@objcMembers
open class ModelSecureBackupTableController: ModelBackupTableController {
    
    private var _nameTextField: UITextField?
    private var _passwordTextField: UITextField?
    private var _passwordConfirmTextField: UITextField?
    override open func addBackupDialog() -> UIAlertController {
        let alertController = UIAlertController(title: "New Protected Backup".localized, message: "Enter name and passsword for this Backup", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK".localized, style: .default, handler: { (action : UIAlertAction) in
            let name = self._nameTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = self._passwordTextField?.text
            if let backup = self.createBackup(name: name!.fileName, password: password!) {
                self.add(backup: backup)
            }
        })
        alertController.addAction(okAction)
        okAlertAction = okAction
        okAlertAction?.isEnabled = false
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
            self._nameTextField = textField
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Password".localized
            textField.autocorrectionType = .no
            textField.spellCheckingType = .no
            textField.autocapitalizationType = .none
            textField.clearButtonMode = .always
            textField.isSecureTextEntry = true
            textField.text = ""
            NotificationCenter.default.addObserver(self, selector: #selector(self.handleTextFieldTextDidChangeNotification), name: UITextField.textDidChangeNotification, object: textField)
            self._passwordTextField = textField
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Confirm Password".localized
            textField.autocorrectionType = .no
            textField.spellCheckingType = .no
            textField.autocapitalizationType = .none
            textField.clearButtonMode = .always
            textField.isSecureTextEntry = true
            textField.text = ""
            NotificationCenter.default.addObserver(self, selector: #selector(self.handleTextFieldTextDidChangeNotification), name: UITextField.textDidChangeNotification, object: textField)
            self._passwordConfirmTextField = textField
        }
        alertController.view?.tintColor = view.tintColor
        return alertController
    }

    @objc
    override open func handleTextFieldTextDidChangeNotification(notification: Notification) {
        if let okAlertAction = okAlertAction {
            let name = _nameTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = _passwordTextField?.text
            let passwordConfirm = _passwordConfirmTextField?.text
            okAlertAction.isEnabled = name?.fileName.isEmpty == false && password?.isEmpty == false && password == passwordConfirm
        }
    }
    
    override open func restoreBackupDialog(backup: Backup) -> UIAlertController {
        let alertController = UIAlertController(title: "Confirm Restore".localized, message: "Enter password to restore Backup".localized, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK".localized, style: .default) { (action) in
            let password = alertController.textFields?.first?.text
            self.restoredWith(success: self.restoreBackup(backup: backup, password: password!))
        }
        alertController.addAction(okAction)
        okAlertAction = okAction
        okAlertAction?.isEnabled = false
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addTextField { (textField) in
            textField.placeholder = "Password".localized
            textField.autocorrectionType = .no
            textField.spellCheckingType = .no
            textField.autocapitalizationType = .none
            textField.clearButtonMode = .always
            textField.isSecureTextEntry = true
            textField.text = ""
            NotificationCenter.default.addObserver(self, selector: #selector(self.handleRestorTextFieldTextDidChangeNotification), name: UITextField.textDidChangeNotification, object: textField)
            self._passwordTextField = textField
        }
        return alertController
    }

    @objc
    open func handleRestorTextFieldTextDidChangeNotification(notification: Notification) {
        let textField = notification.object as! UITextField
        if let okAlertAction = okAlertAction {
            okAlertAction.isEnabled = !textField.text!.isEmpty
        }
    }
    
    // MARK: - Backup
    open func createBackup(name: String, password: String) -> Backup? {
        Model.exportClear()
        defer {
            Model.exportClear()
        }
        do {
            Model.exportState()
            let url = ModelBackupTableController.target.appendingPathComponent(name)
            let success = try dataToBackup(sourceURL: Model.targetExport, targetURL: url, name: name, password: password)
            if success {
                return Backup(name: name, url: url, createdAt: Date())
            }
        } catch {}
        return nil
    }
    
    open func restoreBackup(backup: Backup, password: String) -> Bool {
        Model.exportClear()
        defer {
            Model.exportClear()
        }
        do {
            let success = try backupToData(sourceURL: backup.url, targetURL: Model.targetExport, name: backup.name, password: password)
            if success {
                try Model.target.delete()
                try Model.targetExport.copyFolder(to: Model.target)
                Model.importState()
            }
            return success
        } catch {}
        return false
    }

    open func dataToBackup(sourceURL: URL, targetURL: URL, name: String, password: String) throws -> Bool {
        try sourceURL.copyFolder(to: targetURL)
        return true
    }
    
    open func backupToData(sourceURL: URL, targetURL: URL, name: String, password: String) throws -> Bool {
        try sourceURL.copyFolder(to: targetURL)
        return true
    }
}

