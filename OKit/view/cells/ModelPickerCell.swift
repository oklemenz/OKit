//
//  ModelPickerCell.swift
//  OKit
//
//  Created by Oliver Klemenz on 02.05.19.
//  Copyright © 2020 Oliver Klemenz. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
open class ModelPickerCell: ModelEditCell, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet open var control: UIPickerView?

    private var data: [ModelEntity]?
    
    @IBInspectable open var dataPath: String = "" {
        didSet {
            updateData()
        }
    }
    
    @IBInspectable open var namePath: String = "" {
        didSet {
            updateData()
        }
    }
    
    @IBInspectable open var selectionPath: String = "" {
        didSet {
            updateSelectionPath()
        }
    }
    
    func setupControl() {
        guard control == nil else {
            return
        }
        prepareControl(control)
        if control == nil {
            control = UIPickerView()
            control?.delegate = self
        }
        control?.alpha = 0.0
        control?.applyTheme()
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
        selectionStyle = effectiveEdit ? .none : .default
        UIView.animate(withDuration: 0.25) {
            self.textLabel?.alpha = self.effectiveEdit ? 0.0 : 1.0
            self.detailTextLabel?.alpha = self.effectiveEdit ? 0.0 : 1.0
            self.control?.alpha = self.effectiveEdit ? 1.0 : 0.0
        }
    }
    
    override open func update() {
        super.update()
        updateData()
        updateSelectionPath()
    }

    // MARK: - UIPickerViewDataSource
    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data?.count ?? 0
    }
    
    // MARK: - UIPickerViewDelegate
    open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let rowEntity = data?[row]
        return rowEntity?.getString(namePath)
    }
    
    public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let rowEntity = data?[row]
        if let textColor = UIApplication.theme?.textColor {
            return NSMutableAttributedString(string: rowEntity?.getString(namePath) ?? "",
                                             attributes: [NSAttributedString.Key.foregroundColor: textColor])
        }
        return NSMutableAttributedString(string: rowEntity?.getString(namePath) ?? "")
    }
    
    open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       setSelectionPathKey()
    }
    
    // MARK: - data
    open func updateData() {
        guard !dataPath.isEmpty else {
            return
        }
        fetchData()
        control?.reloadAllComponents()
    }
    
    open var selectedEntity: ModelEntity? {
        guard let control = control, let data = data else {
            return nil
        }
        return data[control.selectedRow(inComponent: 0)]
    }
    
    open func fetchData() {
        data = []
        if !dataPath.isEmpty {
            if let dataArray = effectiveContext?.get(dataPath) as? Array<ModelEntity> {
                data = dataArray
            } else if let dataSet = effectiveContext?.get(dataPath) as? Set<ModelEntity> {
                data = Array<ModelEntity>(dataSet)
            }
        }
    }
    
    // MARK: - key
    open func setSelectionPathKey() {
        guard !selectionPath.isEmpty else {
            return
        }
        if let entity = selectedEntity, let modelRef = effectiveContext?.get(selectionPath) as? ModelRef {
            modelRef.set("refKey", entity.key)
            effectiveContext?.invalidate()
            super.update()
            updateDetail()
        }
    }
    
    open func getSelectionPath() -> String? {
        guard !selectionPath.isEmpty else {
            return nil
        }
        return (effectiveContext?.get(selectionPath) as? ModelRef)?.refKey
    }
    
    open func updateSelectionPath() {
        guard !selectionPath.isEmpty else {
            return
        }
        if let modelRef = effectiveContext?.get(selectionPath) as? ModelRef {
            if let row = data?.firstIndex(where: { (entity) -> Bool in
                return entity.key == modelRef.refKey
            }) {
                control?.selectRow(row, inComponent: 0, animated: false)
            }
            updateDetail()
        }
    }
    
    open func updateDetail() {
        if detailPath.isEmpty {
            detailTextValue = selectedEntity?.getString(namePath)
        }
    }
}
