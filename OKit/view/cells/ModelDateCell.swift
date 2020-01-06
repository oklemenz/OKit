//
//  ModelDateCell.swift
//  OKit
//
//  Created by Klemenz, Oliver on 23.04.19.
//  Copyright © 2020 Klemenz, Oliver. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
open class ModelDateCell: ModelEditCell {
    
    static let ISODateFormatter = ISO8601DateFormatter()

    @IBOutlet open var control: UIDatePicker?
    
    @IBInspectable open var datePath: String = "" {
        didSet {
            updateDate()
        }
    }
    @IBInspectable open var minDatePath: String = "" {
        didSet {
            updateMinDate()
        }
    }
    @IBInspectable open var maxDatePath: String = "" {
        didSet {
            updateMaxDate()
        }
    }
    @IBInspectable open var modePath: String = "#2" {
        didSet {
            updateMode()
        }
    }
    
    deinit {
        control?.removeTarget(self, action: nil, for: .allEvents)
    }
    
    func setupControl() {
        guard control == nil else {
            return
        }
        prepareControl(control)
        if control == nil {
            control = UIDatePicker()
            control?.datePickerMode = .date
        }
        control?.alpha = 0.0
        control?.applyTheme()
        control?.addTarget(self, action: #selector(setDate), for: .valueChanged)
        contentView.addSubview(control!)
        
        control?.translatesAutoresizingMaskIntoConstraints = false
        control?.heightAnchor.constraint(equalToConstant: 216).isActive = true
        control?.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
        control?.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0).isActive = true
        control?.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0).isActive = true
        
        update()
    }
    
    open override func setup() {
        super.setup()
        selectEdit = true
        heightSelect = "#216"
        contentView.clipsToBounds = true
    }
    
    override open func updateEdit() {
        super.updateEdit()
        if effectiveEdit {
            setupControl()
        }
        control?.isEnabled = effectiveEdit
        selectionStyle = effectiveEdit ? .none : .default
        UIView.animate(withDuration: 0.25) {
            self.textLabel?.alpha = self.effectiveEdit ? 0.0 : 1.0
            self.detailTextLabel?.alpha = self.effectiveEdit ? 0.0 : 1.0
            self.control?.alpha = self.effectiveEdit ? 1.0 : 0.0
        }
    }
    
    override open func update() {
        super.update()
        updateDate()
        updateMinDate()
        updateMaxDate()
    }
    
    // MARK: - date
    @objc
    open func setDate() {
        guard !datePath.isEmpty, let control = control else {
            return
        }
        effectiveContext?.set(datePath, control.date)
        updateDetail()
    }
    
    open func getDate() -> Date? {
        guard !datePath.isEmpty else {
            return nil
        }
        return effectiveContext?.get(datePath) as? Date
    }

    open func updateDate() {
        guard !datePath.isEmpty, let control = control else {
            return
        }
        control.date = getDate() ?? Date()
        updateDetail()
    }
    
    open func updateDetail() {
        if detailPath.isEmpty {
            if control?.datePickerMode == .date {
                detailTextValue = control?.date.formatDate
            } else if control?.datePickerMode == .time {
                detailTextValue = control?.date.formatTime
            } else {
                detailTextValue = control?.date.formatDateTime
            }
        }
    }

    // MARK: - minDate
    open func getMinDate() -> Date? {
        guard !minDatePath.isEmpty else {
            return nil
        }
        if let minDate = effectiveContext?.get(minDatePath) as? Date {
            return minDate
        } else if let minDate = effectiveContext?.getString(minDatePath) {
            return ModelDateCell.ISODateFormatter.date(from: minDate)
        }
        return nil
    }
    
    open func updateMinDate() {
        guard !minDatePath.isEmpty else {
            return
        }
        control?.minimumDate = getMinDate()
    }
    
    // MARK: - maxDate
    open func getMaxDate() -> Date? {
        guard !maxDatePath.isEmpty else {
            return nil
        }
        if let maxDate = effectiveContext?.get(maxDatePath) as? Date {
            return maxDate
        } else if let maxDate = effectiveContext?.getString(maxDatePath) {
            return ModelDateCell.ISODateFormatter.date(from: maxDate)
        }
        return nil
    }
    
    open func updateMaxDate() {
        guard !maxDatePath.isEmpty else {
            return
        }
        control?.maximumDate = getMaxDate()
    }
    
    // MARK: - mode
    open func getPickerMode() -> UIDatePicker.Mode {
        guard !modePath.isEmpty else {
            return .dateAndTime
        }
        if let modeValue = effectiveContext?.get(modePath) as? UIDatePicker.Mode {
            return modeValue
        } else if let modeValue = effectiveContext?.getInt(modePath) {
            if let mode = UIDatePicker.Mode(rawValue: modeValue) {
                return mode
            }
        }
        return .dateAndTime
    }
    
    open func updateMode() {
        guard !modePath.isEmpty else {
            return
        }
        control?.datePickerMode = getPickerMode()
    }

}
