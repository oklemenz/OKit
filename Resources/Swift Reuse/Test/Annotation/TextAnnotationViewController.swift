//
//  TextAnnotationViewController.swift
//  Swift Reuse Code
//
//  Created by Oliver Klemenz on 30.07.14.
//
//

import UIKit

protocol TextAnnotationViewControllerDelegate: NSObjectProtocol {
    func didFinishWritingText(_ text: String?, updated: Bool)
}

class TextAnnotationViewController: UIViewController, UITextViewDelegate {
    weak var dataSource: (NSObject & AnnotationDataSource)?
    weak var delegate: TextAnnotationViewControllerDelegate?

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(text: String) {
        super.init(nibName: nil, bundle: nil)
        setText(text)
    }

    func text() -> String? {
        return textView?.text
    }

    func setText(_ text: String?) {
        updateMode = true
        textView?.text = text ?? ""
        if let textView = textView {
            textViewDidChange(textView)
        }
    }

    private var updateMode = false
    private var textView: UITextView?
    private var doneButton: UIBarButtonItem?
    private var dictionaryButton: UIBarButtonItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white

        title = "Write Text".localized

        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(TextAnnotationViewController.done(_:)))
        doneButton?.isEnabled = false

        dictionaryButton = UIBarButtonItem.createCustomTintedTopBarButtonItem("dictionary")
        (dictionaryButton?.customView as? UIButton)?.addTarget(self, action: #selector(TextAnnotationViewController.openDictionary(_:)), for: .touchUpInside)
        navigationItem.rightBarButtonItems = ([doneButton, dictionaryButton] as! [UIBarButtonItem])

        textView = UITextView(frame: view.bounds)
        textView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        textView?.backgroundColor = UIColor.white
        textView?.tintColor = UIColor.black
        textView?.font = UIFont.systemFont(ofSize: 18.0)
        textView?.delegate = self
        textView?.text = "_"
        textView?.text = ""
        if let textView = textView {
            view.addSubview(textView)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(TextAnnotationViewController.keyboardWasShown(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TextAnnotationViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        textView?.isEditable = editing
        if editing {
            navigationItem.rightBarButtonItem = doneButton
            textView?.becomeFirstResponder()
        } else {
            updateMode = true
            navigationItem.rightBarButtonItem = editButtonItem
        }
    }

    @objc func keyboardWasShown(_ notification: Notification?) {
        let keyboardSize: CGSize? = (notification?.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as AnyObject).cgRectValue.size
        if UIDevice.current.orientation.isLandscape {
            textView?.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height - (keyboardSize?.width ?? 0.0))
        } else {
            textView?.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height - (keyboardSize?.height ?? 0.0))
        }
    }

    @objc func keyboardWillHide(_ notification: Notification?) {
    }

    @objc func done(_ sender: Any?) {
        delegate?.didFinishWritingText(textView?.text, updated: updateMode)
    }

    func textViewDidChange(_ textView: UITextView) {
        doneButton?.isEnabled = textView.text.count > 0
        if textView.text.hasSuffix("\n") {
            textView.scrollRectToVisible(CGRect(x: 0, y: textView.contentSize.height - 1, width: 1, height: 1), animated: true)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    @objc func openDictionary(_ sender: Any?) {
        var word: Word?
        if textView?.selectedTextRange != nil {
            var selectedText: String? = nil
            if let selectedTextRange = textView?.selectedTextRange {
                selectedText = textView?.text(in: selectedTextRange)
            }
            if (selectedText?.count ?? 0) > 0 {
                word = Word()
                word?.name = selectedText ?? ""
            }
        }
        if word != nil {
        }
    }

    func didSelectWord(_ word: String?) {
        var word = word
        if !isEditing {
            return
        }
        if (word?.count ?? 0) > 0 {
            let beginning: UITextPosition? = textView?.beginningOfDocument
            let selectionStart: UITextPosition? = textView?.selectedTextRange?.start
            let selectionEnd: UITextPosition? = textView?.selectedTextRange?.end
            var location: Int? = nil
            if let beginning = beginning, let selectionStart = selectionStart {
                location = textView?.offset(from: beginning, to: selectionStart)
            }
            var length: Int? = nil
            if let selectionStart = selectionStart, let selectionEnd = selectionEnd {
                length = textView?.offset(from: selectionStart, to: selectionEnd)
            }
            let selectedRange = NSRange(location: location ?? 0, length: length ?? 0)
            var startLocation: Int = selectedRange.location - 1
            if startLocation < 0 {
                startLocation = 0
            }
            let startRange = NSRange(location: startLocation, length: 1)
            var endLocation: Int = selectedRange.location + selectedRange.length
            if endLocation >= (textView?.text.count ?? 0) {
                endLocation = (textView?.text.count ?? 0) - 1
            }
            if endLocation < 0 {
                endLocation = 0
            }
            if endLocation >= startLocation && startLocation > 0 {
                let endRange = NSRange(location: endLocation, length: 1)
                let lastChar = (textView?.text as NSString?)?.substring(with: startRange)
                let nextChar = (textView?.text as NSString?)?.substring(with: endRange)
                if !(lastChar == " ") && startLocation > 0 {
                    word = " \(word ?? "")"
                }
                if !(nextChar == " ") && endLocation < (textView?.text.count ?? 0) - 1 {
                    word = "\(word ?? "") "
                }
            }
            let textRange: UITextRange? = textView?.selectedTextRange
            if textRange?.isEmpty == nil {
                if let textRange = textRange {
                    textView?.replace(textRange, withText: word ?? "")
                }
            } else {
                textView?.insertText(word ?? "")
            }
        }
        navigationController?.popViewController(animated: true)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
