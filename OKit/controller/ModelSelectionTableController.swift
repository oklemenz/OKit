//
//  ModelSelectionTableController.swift
//  ModelBasedApp
//
//  Created by Klemenz, Oliver on 22.03.19.
//  Copyright © 2019 Klemenz, Oliver. All rights reserved.
//

import Foundation
import UIKit

public protocol ModelSelectionDelegate: class {
    func didSelect(modelRef: ModelRef)
    func didClearSelection(modelRef: ModelRef)
}

@objc
@objcMembers
open class ModelSelectionTableController : ModelListTableController {
    
    public enum SelectionMode: String {
        case single
        case multi
    }

    @IBInspectable open var refType: String = "" // No binding
    @IBInspectable open var refTypeName: String = "" // No binding
    
    private var _selectionContext: ModelEntity?
    open var selectionContext: ModelEntity? {
        get {
            return _selectionContext ?? Model.getDefault()
        }
        set {
            _selectionContext = newValue
            update()
        }
    }
    
    open func resetSelectionContext() {
        self.selectionContext = nil
        update()
    }
    
    open func selectionContext(_ context: ModelEntity?, owner: AnyObject?) {
        self.selectionContext = context
        update()
    }
    
    @IBInspectable open var selectionContextPath: String = "" {
        didSet {
            update()
        }
    }

    open var effectiveSelectionContext: ModelEntity? {
        if !selectionContextPath.isEmpty {
            return selectionContext?.resolve(selectionContextPath)
        }
        return selectionContext
    }
    
    @IBInspectable open var selectionPath: String = ""
    @IBInspectable open var selectAppend: String = "#false"
    @IBInspectable open var unique: String = "#true"
    @IBInspectable open var unselect: String = "#true"
    @IBInspectable open var clear: String = "#true" {
        didSet {
            handleClear()
        }
    }
    @IBInspectable open var close: String = "#true" {
        didSet {
            handleClose()
        }
    }
    @IBInspectable open var autoClose: String = "#false"
    
    open var selectionMode: SelectionMode = .single
    open var selectionRefs: [ModelEntity] = []
    open var selectionRef: ModelEntity? {
        get {
            return selectionRefs.first
        }
        set {
            selectionRefs = []
            if let selectedRef = newValue {
                selectionRefs = [selectedRef]
            }
        }
    }

    weak open var delegate: ModelSelectionDelegate?

    override open func setup() {
        super.setup()
        handleClear()
        handleClose()
    }
    
    open func refreshState() {
        if (!autoClose.isEmpty && effectiveSelectionContext?.getBool(autoClose) == true) || (autoClose.isEmpty && selectionMode == .single) {
            close()
        } else {
            update()
        }
    }
    
    // MARK: - Context
    override open func update(animated: Bool = false) {
        super.update(animated: animated)
        updateSelection()
    }
    
    open func updateSelection() {
        guard isSelectionReady else {
            return
        }
        selectionRefs = []
        if !selectionPath.isEmpty {
            if let selectedRef = effectiveSelectionContext?.get(selectionPath) as? ModelRef {
                selectionRefs.append(selectedRef)
                selectionMode = .single
            } else if let selectedRefArray = effectiveSelectionContext?.get(selectionPath) as? Array<ModelRef> {
                selectionRefs = selectedRefArray
                selectionMode = .multi
            } else if let selectedRefSet = effectiveSelectionContext?.get(selectionPath) as? Set<ModelRef> {
                selectionRefs = Array<ModelRef>(selectedRefSet)
                selectionMode = .multi
            }
        }
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.accessoryView = nil
        if let entity = getEntity(indexPath), selectionRefs.contains(where: { (modelRef) -> Bool in
            return (modelRef as? ModelRef)?.ref == entity
        }) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let entity = getEntity(indexPath), let _ = entity.key else {
            return
        }
        let alreadySelected = selectionRefs.contains { (modelRef) -> Bool in
            return (modelRef as? ModelRef)?.ref == entity
        }
        switch selectionMode {
        case .single:
            if !alreadySelected {
                selectSingle(entity)
            } else if effectiveSelectionContext?.getBool(unselect) == true {
                unselectSingle()
            }
        case .multi:
            if alreadySelected && effectiveSelectionContext?.getBool(unique) == true {
                if effectiveSelectionContext?.getBool(unselect) == true {
                    unselectMultiple(entity)
                }
            } else {
                selectMultiple(entity)
            }
        }
        setSelectionData()
        refreshState()
    }
    
    open func selectSingle(_ entity: ModelEntity) {
        if let modelRef = effectiveSelectionContext?.get(selectionPath) as? ModelRef {
            modelRef.set("refKey", entity.key)
            delegate?.didSelect(modelRef: modelRef)
            selectionRef = modelRef
        }
    }
    
    open func unselectSingle() {
        if let modelRef = effectiveSelectionContext?.get(selectionPath) as? ModelRef {
            modelRef.set("refKey", nil)
            delegate?.didClearSelection(modelRef: modelRef)
            selectionRef = nil
        }
    }
    
    open func selectMultiple(_ entity: ModelEntity) {
        let selectionTarget = effectiveSelectionContext?.resolve(selectionPath)
        if let modelRef = selectionTarget?.add(&selectionRefs, type: ModelRef.typeClass(refType), append: effectiveSelectionContext?.getBool(selectAppend) == true) as? ModelRef {
            modelRef.set("refKey", entity.key)
            delegate?.didSelect(modelRef: modelRef)
        }
    }
    
    open func unselectMultiple(_ entity: ModelEntity? = nil) {
        let selectionTarget = effectiveSelectionContext?.resolve(selectionPath)
        if let entity = entity {
            if let modelRef = selectionRefs.first(where: { (modelRef) -> Bool in
                return (modelRef as? ModelRef)?.ref == entity
            }) as? ModelRef {
                _ = selectionTarget?.remove(&selectionRefs, entity: modelRef)
                delegate?.didClearSelection(modelRef: modelRef)
            }
        } else {
            selectionTarget?.clear(&selectionRefs)
            for modelRef in selectionRefs {
                delegate?.didClearSelection(modelRef: modelRef as! ModelRef)
            }
        }
    }
    
    open func setSelectionData() {
        makeOwner()
        if !selectionPath.isEmpty {
            switch selectionMode {
            case .single:
                break
            case .multi:
                if let _ = effectiveSelectionContext?.get(selectionPath) as? Set<ModelRef> {
                    effectiveSelectionContext?.set(selectionPath, Set<ModelEntity>(selectionRefs))
                } else {
                    effectiveSelectionContext?.set(selectionPath, selectionRefs)
                }
            }
        }
    }
    
    private var clearBarButton: ModelBarButtonItem!
    open func handleClear() {
        if clearBarButton == nil {
            clearBarButton = ModelBarButtonItem(title: "Clear".localized, style: .plain, target: self, action: #selector(onClearTap(_:)))
            clearBarButton.managed = true
        }
        navigationItem.rightBarButtonItems = navigationItem.rightBarButtonItems ?? []
        let index = navigationItem.rightBarButtonItems!.firstIndex(of: clearBarButton)
        if effectiveSelectionContext?.getBool(clear) == true {
            if index == nil  {
                navigationItem.rightBarButtonItems!.insert(clearBarButton, at: 0)
            }
        } else {
            if let index = index {
                navigationItem.rightBarButtonItems!.remove(at: index)
            }
        }
    }

    @objc
    open func onClearTap(_ barButtonItem: ModelBarButtonItem) {
        switch selectionMode {
        case .single:
            unselectSingle()
        case .multi:
            unselectMultiple()
        }
        setSelectionData()
        refreshState()
    }
   
    private var closeBarButton: ModelBarButtonItem!
    open func handleClose() {
        guard isModal else {
            return
        }
        if closeBarButton == nil {
            closeBarButton = ModelBarButtonItem(title: "Close".localized, style: .plain, target: self, action: #selector(onCloseTap(_:)))
            closeBarButton.managed = true
        }
        navigationItem.leftBarButtonItems = navigationItem.leftBarButtonItems ?? []
        let index = navigationItem.leftBarButtonItems!.firstIndex(of: closeBarButton)
        if effectiveSelectionContext?.getBool(close) == true {
            if index == nil  {
                navigationItem.leftBarButtonItems!.insert(closeBarButton, at: 0)
            }
        } else {
            if let index = index {
                navigationItem.leftBarButtonItems!.remove(at: index)
            }
        }
    }
    
    @objc
    open func onCloseTap(_ barButtonItem: ModelBarButtonItem) {
        close()
    }
    
    open var isSelectionReady: Bool {
        return viewIfLoaded != nil && effectiveSelectionContext != nil
    }
}
