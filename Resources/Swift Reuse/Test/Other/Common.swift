//
//  Common.swift
//  Swift Reuse Code
//
//  Created by Oliver Klemenz on 08.01.15.
//
//

import Foundation
import UIKit

class Common: NSObject {
let kActionSheetAnnotationCancel = 0
let kActionSheetAnnotationAdd = 1
let kActionSheetAnnotationShow = 2
let kActionSheetAnnotationNavigate = 3
let kActionSheetAnnotationClear = 4
let kActionSheetAnnotationRemove = 5
    
    class func showDeletionConfirmation(_ presenter: UIViewController?, okHandler: @escaping () -> Void, cancelHandler: @escaping () -> Void) -> UIAlertController? {
        return Common.showConfirmation(presenter, title: "Confirm Deletion".localized, message: "Data is irreversibly deleted. Do you want to continue?".localized, okButtonTitle: "Delete".localized, destructive: true, okHandler: okHandler, cancelHandler: cancelHandler)
    }

    class func showEditConfirmation(_ presenter: UIViewController?, okHandler: @escaping () -> Void, cancelHandler: @escaping () -> Void) -> UIAlertController? {
        return Common.showConfirmation(presenter, title: NSLocalizedString("Edit Completed School Year?", comment: ""), message: NSLocalizedString("Do you want to edit school year that is neither active nor in planning?", comment: ""), okButtonTitle: NSLocalizedString("Edit", comment: ""), destructive: false, okHandler: okHandler, cancelHandler: cancelHandler)
    }

    class func showConfirmation(_ presenter: UIViewController?, title: String?, message: String?, okButtonTitle: String?, destructive: Bool, okHandler: @escaping () -> Void, cancelHandler: @escaping () -> Void) -> UIAlertController? {
        return Common.showConfirmation(presenter, title: title, message: message, okButtonTitle: okButtonTitle, destructive: destructive, cancelButtonTitle: nil, okHandler: okHandler, cancelHandler: cancelHandler)
    }

    class func showConfirmation(_ presenter: UIViewController?, title: String?, message: String?, okButtonTitle: String?, destructive: Bool, cancelButtonTitle: String?, okHandler: @escaping () -> Void, cancelHandler: @escaping () -> Void) -> UIAlertController? {

        var _okButtonTitle = okButtonTitle
        if _okButtonTitle == nil {
            _okButtonTitle = NSLocalizedString("OK", comment: "")
        }
        var _cancelButtonTitle = cancelButtonTitle
        if _cancelButtonTitle == nil {
            _cancelButtonTitle = NSLocalizedString("Cancel", comment: "")
        }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: _cancelButtonTitle, style: .cancel, handler: { action in
            //if cancelHandler
            cancelHandler()
        }))

        alert.addAction(UIAlertAction(title: _okButtonTitle, style: destructive ? .destructive : .default, handler: { action in
            //if okHandler
            okHandler()
        }))
        return alert
    }

    class func showMessage(_ presenter: UIViewController?, title: String?, message: String?, okHandler: @escaping () -> Void) -> UIAlertController? {
        return Common.showMessage(presenter, title: title, message: message, okButtonTitle: nil, okHandler: okHandler)
    }

    class func showMessage(_ presenter: UIViewController?, title: String?, message: String?, okButtonTitle: String?, okHandler: @escaping () -> Void) -> UIAlertController? {

        var _okButtonTitle = okButtonTitle
        if _okButtonTitle == nil {
            _okButtonTitle = NSLocalizedString("OK", comment: "")
        }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: _okButtonTitle, style: .default, handler: { action in
            //if okHandler
            okHandler()
        }))
        return alert
    }

    class func showEnterPasscode(_ presenter: UIViewController?, okHandler: @escaping (_ passcode: String?) -> Void, cancelHandler: @escaping () -> Void) -> UIAlertController? {
        let alert = UIAlertController(title: NSLocalizedString("Enter Application Passcode", comment: ""), message: nil, preferredStyle: .alert)

        weak var weakAlert: UIAlertController? = alert
        let handleNotification: ((_ note: Notification?) -> Void)? = { note in
                let password: UITextField? = weakAlert?.textFields?.first
                let okAction: UIAlertAction? = weakAlert?.actions.first
                okAction?.isEnabled = (password?.text?.count ?? 0) > 0
            }

        alert.addTextField(configurationHandler: { textField in
            textField.keyboardType = .numberPad
            textField.placeholder = NSLocalizedString("Passcode", comment: "")
            textField.isSecureTextEntry = true
            if let handleNotification = handleNotification {
                NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: nil, queue: OperationQueue.main, using: handleNotification)
            }
        })

        let ok = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { action in
                NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
                let passcode: UITextField? = alert.textFields?.first
                //if okHandler
                okHandler(passcode?.text)
            })
        ok.isEnabled = false
        alert.addAction(ok)

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { action in
            NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
            //if cancelHandler
            cancelHandler()
        }))
        return alert
    }

    class func showNotificationConfirmation(_ presenter: UIViewController?, showHandler: @escaping () -> Void, openHandler: @escaping () -> Void, cancelHandler: @escaping () -> Void) -> UIAlertController? {

        let alert = UIAlertController(title: NSLocalizedString("Annotation Reminder ", comment: ""), message: NSLocalizedString("Do you want to show or navigate to the annotation?", comment: ""), preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { action in
            //if cancelHandler
            cancelHandler()
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("Navigate to Annotation", comment: ""), style: .default, handler: { action in
            //if openHandler
            openHandler()
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("Show Annotation", comment: ""), style: .default, handler: { action in
            //if showHandler
            showHandler()
        }))
        return alert
    }

    class func showText(_ presenter: UIViewController?, okHandler: @escaping (_ text: String?) -> Void, cancelHandler: @escaping () -> Void) -> UIAlertController? {
        let alert = UIAlertController(title: NSLocalizedString("Enter Annotation Text", comment: ""), message: nil, preferredStyle: .alert)

        weak var weakAlert: UIAlertController? = alert
        let handleNotification: ((_ note: Notification?) -> Void)? = { note in
                let text: UITextField? = weakAlert?.textFields?.first
                let okAction: UIAlertAction? = weakAlert?.actions.first
                okAction?.isEnabled = (text?.text?.count ?? 0) > 0
            }

        alert.addTextField(configurationHandler: { textField in
            textField.keyboardType = .alphabet
            textField.placeholder = NSLocalizedString("Text", comment: "")
            textField.isSecureTextEntry = true
            if let handleNotification = handleNotification {
                NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: nil, queue: OperationQueue.main, using: handleNotification)
            }
        })

        let ok = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { action in
                NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
                let text: UITextField? = alert.textFields?.first
                //if okHandler
                okHandler(text?.text)
            })
        ok.isEnabled = false
        alert.addAction(ok)

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { action in
            NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
            //if cancelHandler
            cancelHandler()
        }))
        return alert
    }

    class func showAnnotationAlertSheet(_ presenter: UIViewController?, handler: @escaping (_ option: Int) -> Void, existing: Bool) -> UIAlertController? {
        let alert = UIAlertController(title: NSLocalizedString("Annotations", comment: ""), message: NSLocalizedString("Select an option", comment: ""), preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: NSLocalizedString("Add Annotation with reminder", comment: ""), style: .default, handler: { action in
            handler(0 /*kActionSheetAnnotationAdd*/)
        }))

        if existing {
            alert.addAction(UIAlertAction(title: NSLocalizedString("Show Annotation", comment: ""), style: .default, handler: { action in
                handler(1 /*kActionSheetAnnotationShow*/)
            }))

            alert.addAction(UIAlertAction(title: NSLocalizedString("Navigate to Annotation", comment: ""), style: .default, handler: { action in
                handler(2 /*kActionSheetAnnotationNavigate*/)
            }))

            alert.addAction(UIAlertAction(title: NSLocalizedString("Clear Reminder", comment: ""), style: .default, handler: { action in
                handler(3 /*kActionSheetAnnotationRemove*/)
            }))

            alert.addAction(UIAlertAction(title: NSLocalizedString("Remove Annotation", comment: ""), style: .default, handler: { action in
                handler(4 /*kActionSheetAnnotationRemove*/)
            }))
        }

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { action in
            handler(5 /*kActionSheetAnnotationCancel*/)
        }))
        return alert
    }
}
