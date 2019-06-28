//
//  ModelTableController.swift
//  OKit
//
//  Created by Klemenz, Oliver on 27.02.19.
//  Copyright © 2019 Klemenz, Oliver. All rights reserved.
//

import Foundation
import UIKit

@objc
@objcMembers
open class ModelListTableController : ModelBaseTableController, UISearchBarDelegate, UISearchResultsUpdating {
    
    private var _navEntity: ModelEntity?
    private var _navEntityNew: Bool = false
    
    private var data: [ModelEntity]?
    
    private var tableData: [ModelEntity]?
    private var sections: [String] = []
    private var sectionNames: [String:String] = [:]
    private var sectionData: [String:[ModelEntity]] = [:]
    private var searchText: String = ""

    @IBInspectable open var type: String = "" // No binding
    @IBInspectable open var typeName: String = "" // No binding
    @IBInspectable open var dataPath: String = "" {
        didSet {
            update()
        }
    }
    @IBInspectable open var rowSort: String = "" {
        didSet {
            update()
        }
    }
    @IBInspectable open var rowSortAsc: String = "#true" {
        didSet {
            update()
        }
    }
    @IBInspectable open var group: String = "" {
        didSet {
            update()
        }
    }
    private var _groupName: String = ""
    @IBInspectable open var groupName: String {
        get {
            return !_groupName.isEmpty ? _groupName : group
        }
        set {
            _groupName = newValue
            update()
        }
    }
    @IBInspectable open var groupSort: String = "#true" {
        didSet {
            update()
        }
    }
    @IBInspectable open var groupSortAsc: String = "#true" {
        didSet {
            update()
        }
    }
    @IBInspectable open var reorder: String = "#false" {
        didSet {
            update()
        }
    }
    @IBInspectable open var reorderEnabled: String = "#true" {
        didSet {
            update()
        }
    }
    @IBInspectable open var tap: String = ""
    @IBInspectable open var tapEdit: String = ""
    @IBInspectable open var selectPath: String = ""
    @IBInspectable open var refresh: String = "#true" {
        didSet {
            handleRefresh()
        }
    }
    @IBInspectable open var search: String = "#true" {
        didSet {
            handleSearch()
        }
    }
    @IBInspectable open var searchPath: String = "description"
    @IBInspectable open var searchFilterPath: String = ""
    @IBInspectable open var searchFilters: String = ""
    private var searchFilterValues: [String] = []
    
    @IBInspectable open var index: String = "#false" {
        didSet {
            update()
        }
    }
    @IBInspectable open var add: String = "#true" {
        didSet {
            handleAdd()
        }
    }
    @IBInspectable open var addAppend: String = "#false"
    @IBInspectable open var addName: String = "" // No binding
    @IBInspectable open var addNav: String = "#false"
    @IBInspectable open var navEnabled: String = "#true"
    @IBInspectable open var delete: String = "#true"
    @IBInspectable open var deleteEnabled: String = "#true"
    @IBInspectable open var deletePrompt: String = "#true"
    @IBInspectable open var more: String = "#false"
    @IBInspectable open var moreEnabled: String = "#true"
    @IBInspectable open var moreTap: String = ""
    @IBInspectable open var moreActions: String = ""
    @IBInspectable open var moreActionsEnabled: String = ""
    @IBInspectable open var moreActionsTap: String = ""
    @IBInspectable open var quickName: String = ""
    @IBInspectable open var quickImage: String = ""
    @IBInspectable open var quickEnabled: String = "#true"
    @IBInspectable open var quickTap: String = ""
    @IBInspectable open var autoDeselect: String = "#true"
    @IBInspectable open var forceListUpdate: String = "#false"
    
    // MARK: - Setup
    override open func setup() {
        super.setup()
        handleAdd()
        handleSearch()
        handleRefresh()
        handleActivity()
    }

    // MARK: - Context
    override open func updateData() {
        fetchData()
        tableData = data
        filterData()
        sortData(&tableData)
        buildSections()
    }

    open func fetchData() {
        data = []
        clearSections()
        if !dataPath.isEmpty {
            if let dataArray = effectiveContext?.get(dataPath) as? Array<ModelEntity> {
                data = dataArray
            } else if let dataSet = effectiveContext?.get(dataPath) as? Set<ModelEntity> {
                data = Array<ModelEntity>(dataSet)
            }
        }
    }
    
    open func filterData() {
        if !searchText.isEmpty {
            tableData = tableData?.filter({( entity : ModelEntity) -> Bool in
                return (entity.getString(searchPath) ?? "").searchNormalized.contains(searchText.searchNormalized)
            })
        }
        if searchController?.searchBar.selectedScopeButtonIndex ?? 0 > 0 {
            let filter = searchFilterValues[searchController!.searchBar.selectedScopeButtonIndex]
            tableData = tableData?.filter({( entity : ModelEntity) -> Bool in
                return (entity.getString(searchFilterPath) ?? "") == filter
            })
        }
    }
    
    open func sortData(_ data: inout [ModelEntity]?) {
        if !rowSort.isEmpty {
            data?.sort(by: { (a, b) -> Bool in
                if let valA = a.get(rowSort), let valB = b.get(rowSort) {
                    if effectiveContext?.getBool(rowSortAsc) == true {
                        return "\(valA)" < "\(valB)"
                    } else {
                        return "\(valA)" > "\(valB)"
                    }
                }
                return false
            })
        }
    }
    
    private func clearSections() {
        sections = []
        sectionNames = [:]
        sectionData = [:]
    }
    
    private func buildSections() {
        clearSections()
        if !group.isEmpty {
            for entity in tableData! {
                _ = addEntityToSection(entity)
            }
        }
        sortSections();
    }
    
    private func addEntityToSection(_ entity: ModelEntity, append: Bool? = true, sort: Bool = false) -> Bool {
        var sectionAdd = false
        var groupValue = "\(entity.get(group) ?? "")"
        let groupNameValue = !groupName.isEmpty ? (entity.getString(groupName) ?? "") : groupValue
        if let section = sectionNames.first(where: { $0.value == groupNameValue })?.key {
            groupValue = section
        } else {
            if append == true {
                sections.append(groupValue)
            } else {
                sections.insert(groupValue, at: 0)
            }
            sectionNames[groupValue] = groupNameValue
            sectionAdd = true
        }
        if sectionData[groupValue] == nil {
            sectionData[groupValue] = []
        }
        if append == true {
            sectionData[groupValue]?.append(entity)
        } else {
            sectionData[groupValue]?.insert(entity, at: 0)
        }
        if sort {
            sortData(&sectionData[groupValue])
        }
        return sectionAdd
    }
    
    private func removeEntityFromSection(_ entity: ModelEntity) -> Bool {
        var sectionDelete = false
        sections = sections.filter({ (section) in
            if let index = sectionData[section]?.firstIndex(of: entity) {
                sectionData[section]?.remove(at: index)
                if sectionData[section]?.isEmpty == true {
                    sectionNames.removeValue(forKey: section)
                    sectionDelete = true
                    return false
                }
            }
            return true
        })
        return sectionDelete
    }
    
    private func sortSections() {
        if effectiveContext?.getBool(groupSort) == true {
            if effectiveContext?.getBool(groupSortAsc) == false {
                sections.sort(by: >)
            } else {
                sections.sort(by: <)
            }
        }
    }
    
    // MARK: - Update
    override open func updateTable(animated: Bool = false, completion: ModelCompletion? = nil) {
        if effectiveContext?.getBool(activity) == true {
            startActivity()
        }
        super.updateTable(animated: animated) { (completed) in
            if self.effectiveContext?.getBool(self.activity) == true {
                self.stopActivity()
            }
        }
    }
    
    // MARK: - Table
    override open func numberOfSections(in tableView: UITableView) -> Int {
        return group.isEmpty ? 1 : sections.count
    }
    
    override open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return group.isEmpty ? nil : sectionNames[sections[section]]
    }
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (group.isEmpty ? tableData?.count : sectionData[sections[section]]?.count) ?? 0
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Model.Identifier, for: indexPath)
        let entity = getEntity(indexPath)
        cell.context(entity, owner: self)
        cell.accessoryView = accessoryViewFor(cell, entity: entity, indexPath: indexPath, edit: false)
        cell.accessoryView?.context(entity, owner: self)
        cell.editingAccessoryView = accessoryViewFor(cell, entity: entity, indexPath: indexPath, edit: true)
        cell.editingAccessoryView?.context(entity, owner: self)
        return cell
    }
    
    override open func heightForCell(context: ModelEntity?, cell: UITableViewCell, indexPath: IndexPath) -> CGFloat? {
        return super.heightForCell(context: getEntity(indexPath), cell: cell, indexPath: indexPath)
    }
    
    open func accessoryViewFor(_ cell: UITableViewCell, entity: ModelEntity?, indexPath: IndexPath, edit: Bool) -> UIView? {
        let accessoryView = edit ? cell.editingAccessoryView : cell.accessoryView
        guard accessoryView == nil || (accessoryView as? ModelButton)?.managed == true, let modelCell = cell as? ModelTableCell else {
            return accessoryView
        }
        let showPath = edit ? modelCell.accyEditShow : modelCell.accyShow
        guard entity?.getBool(showPath) == true else {
            return nil
        }
        let iconPath = edit ? modelCell.accyEditIcon : modelCell.accyIcon
        let textPath = edit ? modelCell.accyEditText : modelCell.accyText
        let enabledPath = edit ? modelCell.accyEditEnabled : modelCell.accyEnabled
        var button = accessoryView as? ModelButton
        if !iconPath.isEmpty || !textPath.isEmpty {
            if button == nil {
                button = ModelButton()
                button?.managed = true
                button?.addTarget(self, action: NSSelectorFromString("didTapAccessoryButton:"), for: .touchUpInside)
                button?.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            }
            button?.iconPath = iconPath
            button?.titlePath = textPath
            button?.enabledPath = enabledPath
        }
        return button
    }
    
    override open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let entity = getEntity(indexPath)
        return effectiveContext?.getBool(edit) == true && entity?.getBool(editEnabled) == true
    }
    
    override open func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let entity = getEntity(indexPath)
        var actions: [UIContextualAction] = []
        if ((!quickName.isEmpty || !quickImage.isEmpty) && entity?.getBool(quickEnabled) == true) {
            let action = UIContextualAction(style: .normal, title: entity?.getString(quickName) ?? "", handler: { (action, view, completion) in
                self.onQuickTap(indexPath: indexPath, completion: completion)
            })
            if !quickImage.isEmpty {
                action.image = entity?.getImage(quickImage)
            }
            action.backgroundColor = view.tintColor
            actions.append(action)
        }
        return UISwipeActionsConfiguration(actions: actions)
    }
    
    override open func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let entity = getEntity(indexPath)
        var actions: [UIContextualAction] = []
        if effectiveContext?.getBool(delete) == true && entity?.getBool(deleteEnabled) == true {
            actions.append(UIContextualAction(style: .destructive, title: "Delete".localized, handler: { (action, view, completion) in
                self.onDelete(indexPath: indexPath, completion: completion)
            }))
        }
        if effectiveContext?.getBool(more) == true && entity?.getBool(moreEnabled) == true {
            actions.append(UIContextualAction(style: .normal, title: "More...".localized, handler: { (action, view, completion) in
                self.onMoreTap(indexPath: indexPath, completion: completion)
            }))
        }
        return UISwipeActionsConfiguration(actions: actions)
    }
    
    override open func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        let entity = getEntity(indexPath)
        return group.isEmpty && effectiveContext?.getBool(reorder) == true && entity?.getBool(reorderEnabled) == true
    }
    
    override open func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if effectiveContext?.getBool(reorder) == true {
            if let entity = getEntity(sourceIndexPath), let destinationEntity = getEntity(destinationIndexPath) {
                // Table Data
                let destinationIndex = data?.firstIndex(of: destinationEntity)
                if let index = tableData?.firstIndex(of: entity) {
                    tableData?.remove(at: index)
                }
                tableData?.insert(entity, at: destinationIndexPath.row)
                // Data
                if let index = data?.firstIndex(of: entity) {
                    data?.remove(at: index)
                }
                if let index = destinationIndex {
                    data?.insert(entity, at: index)
                } else {
                    data?.append(entity)
                }
                setData()
            }
        }
        DispatchQueue.main.async {
            self.clearSelection()
        }
    }
    
    override open func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return tableView.allowsMultipleSelectionDuringEditing ? .none : .delete
    }
    
    override open func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if sourceIndexPath.section != proposedDestinationIndexPath.section {
            var row = 0
            if sourceIndexPath.section < proposedDestinationIndexPath.section {
                row = self.tableView(tableView, numberOfRowsInSection: sourceIndexPath.section) - 1
            }
            return IndexPath(row: row, section: sourceIndexPath.section)
        }
        return proposedDestinationIndexPath
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        if isEditing && tableView.allowsMultipleSelectionDuringEditing, !selectPath.isEmpty {
            _ = getEntity(indexPath)?.set(selectPath, true)
            return
        }
        if effectiveContext?.getBool(autoDeselect) == true {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        if isEditing {
            // textFieldBecomeFirstResponder(indexPath: indexPath)
        } else {
            if !tap.isEmpty {
                onTap(indexPath: indexPath)
            }
        }
    }
    
    override open func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if isEditing, tableView.allowsMultipleSelectionDuringEditing, !selectPath.isEmpty {
            _ = getEntity(indexPath)?.set(selectPath, false)
        }
    }
        
    override open func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        onAccessoryTap(indexPath: indexPath)
    }
    
    open func onTap(indexPath: IndexPath) {
        let tapPath = isEditing ? tapEdit : tap
        if !tapPath.isEmpty {
            _ = getEntity(indexPath)?.get(tapPath)
        }
    }
    
    open func onAccessoryTap(indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ModelTableCell {
            let tapPath = isEditing ? cell.accyEditTap : cell.accyTap
            if !tapPath.isEmpty {
                _ = getEntity(indexPath)?.get(tapPath)
            }
        }
    }
    
    @objc
    open func didTapAccessoryButton(_ button: ModelButton) {
        if let indexPath = button.indexPath, let entity = getEntity(indexPath) {
            if let cell = tableView.cellForRow(at: indexPath) as? ModelTableCell {
                let path = isEditing ? cell.accyEditTap : cell.accyTap
                makeOwner()
                entity.call(path, completion: { (completed) in
                    self.update()
                })
            }
        }
    }
    
    // MARK: - Core
    private var addBarButton: ModelBarButtonItem!
    open func handleAdd() {
        if addBarButton == nil {
            addBarButton = ModelBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddTap(_:)))
            addBarButton.managed = true
        }
        navigationItem.rightBarButtonItems = navigationItem.rightBarButtonItems ?? []
        let index = navigationItem.rightBarButtonItems!.firstIndex(of: addBarButton)
        if effectiveContext?.getBool(add) == true {
            if index == nil  {
                navigationItem.rightBarButtonItems!.insert(addBarButton, at: 0)
            }
        } else {
            if let index = index {
                navigationItem.rightBarButtonItems!.remove(at: index)
            }
        }
    }
    
    private var okAlertAction: UIAlertAction?
    @objc
    open func onAddTap(_ barButtonItem: UIBarButtonItem) {
        guard data != nil else {
            return
        }
        if !addName.isEmpty {
            let typeNameValue = !typeName.isEmpty ? typeName : type
            let alertController = UIAlertController(title: "New \(typeNameValue)".localized, message: "Enter \(addName) for this \(typeNameValue)".localized, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK".localized, style: .default, handler: { (action : UIAlertAction) in
                let text = alertController.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                DispatchQueue.main.async {
                    self.addEntity(text)
                }
            })
            okAction.isEnabled = false
            alertController.addAction(okAction)
            okAlertAction = okAction
            let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            alertController.addTextField { (textField) in
                textField.autocorrectionType = .yes
                textField.spellCheckingType = .yes
                textField.autocapitalizationType = .sentences
                textField.clearButtonMode = .always
                textField.placeholder = self.addName.capitalize
                NotificationCenter.default.addObserver(self, selector: #selector(self.handleTextFieldTextDidChangeNotification), name: UITextField.textDidChangeNotification, object: textField)
            }
            alertController.view?.tintColor = view.tintColor
            self.present(alertController, animated: true, completion: nil)
        } else {
            addEntity()
        }
    }
    
    @objc
    open func handleTextFieldTextDidChangeNotification(notification: Notification) {
        let textField = notification.object as! UITextField
        if let okAlertAction = okAlertAction {
            okAlertAction.isEnabled = !textField.text!.isEmpty
        }
    }
    
    open func onQuickTap(indexPath: IndexPath, completion: ModelCompletion?) {
        onQuickAction(indexPath: indexPath) { (completed) in
            self.tableView.performBatchUpdates({
                self.tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
            }, completion: completion)
        }
    }
    
    open func onQuickAction(indexPath: IndexPath, completion: ModelCompletion?) {
        makeOwner()
        getEntity(indexPath)?.call(quickTap, completion: completion)
    }
    
    open func onDelete(indexPath: IndexPath, completion: ModelCompletion?) {
        if effectiveContext?.getBool(deletePrompt) == true {
            let alert = UIAlertController(title: "Confirm Deletion".localized, message: "Do you really want to delete entry?".localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes".localized, style: .default) { (action) in
                self.deleteEntity(indexPath)
                completion?(true)
            })
            alert.addAction(UIAlertAction(title: "No".localized, style: .cancel) { (action) in
                completion?(false)
            })
            present(alert, animated: true)
        } else {
            deleteEntity(indexPath)
            completion?(true)
        }
    }
    
    open func onMoreTap(indexPath: IndexPath, completion: ModelCompletion?) {
        onMoreAction(indexPath: indexPath, completion: completion)
    }
    
    open func onMoreAction(indexPath: IndexPath, completion: ModelCompletion?) {
        makeOwner()
        let entity = getEntity(indexPath)
        if !moreTap.isEmpty {
            entity?.call(moreTap, completion: completion)
        } else if !moreActions.isEmpty {
            let actions = moreActions.multiParts
            let actionsTap = moreActionsTap.multiParts
            let actionsEnabled = moreActionsEnabled.multiParts
            
            let title = tableView.cellForRow(at: indexPath)?.textLabel?.text ?? titleStringValue
            let alertController = UIAlertController(title: title, message: "Select an action".localized, preferredStyle: .actionSheet)
            
            let internalCompletion: ModelCompletion = { (completed) in
                self.tableView.performBatchUpdates({
                    self.tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
                }) { (_) in
                    completion?(completed)
                }
            }
            for (index, action) in actions.enumerated() {
                if index < actionsEnabled.count && !actionsEnabled[index].isEmpty ? entity?.getBool(actionsEnabled[index]) == true : true {
                    if let actionName = entity?.getString(action) {
                        let action = UIAlertAction(title: actionName, style: .default) { (action: UIAlertAction) in
                            if index < actionsTap.count {
                                entity?.call(actionsTap[index], completion: internalCompletion)
                            } else {
                                completion?(true)
                            }
                        }
                        alertController.addAction(action)
                    }
                }
            }
            
            let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel) { (action: UIAlertAction) in
                completion?(true)
            }
            alertController.addAction(cancel)
            
            present(alertController, animated: true, completion: nil)
        }
    }
    
    open func getEntity(_ indexPath: IndexPath) -> ModelEntity? {
        if group.isEmpty {
            return tableData?[indexPath.row]
        } else {
            return sectionData[sections[indexPath.section]]?[indexPath.row]
        }
    }
    
    open func addEntity(_ text: String? = nil) {
        let target = effectiveContext?.resolve(dataPath)
        let append = effectiveContext?.getBool(addAppend) == true
        if let newEntity = target?.add(&data!, type: type, append: append) {
            target?.add(&tableData!, entity: newEntity, append: append)
            if !addName.isEmpty {
                newEntity.set(addName, text)
            }
            sortData(&tableData)
            if group.isEmpty {
                if let row = tableData?.firstIndex(of: newEntity) {
                    let indexPath = IndexPath(row: row, section: 0)
                    tableView.insertRows(at: [indexPath], with: .top)
                    tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                }
            } else {
                let sectionAdd = addEntityToSection(newEntity, append: append, sort: true)
                sortSections()
                var row: Int?
                if let section = sections.firstIndex(where: { (section) -> Bool in
                    row = sectionData[section]?.firstIndex(of: newEntity)
                    return row != nil
                }), let row = row {
                    let indexPath = IndexPath(row: row, section: section)
                    tableView.performBatchUpdates({
                        if sectionAdd {
                            tableView.insertSections(IndexSet(integer: indexPath.section), with: .top)
                        }
                        tableView.insertRows(at: [indexPath], with: .top)
                    }, completion: nil)
                }
            }
            setData()
            if effectiveContext?.getBool(addNav) == true {
                navigateTo(entity: newEntity, isNew: true)
            }
        }
    }
    
    open func deleteEntity(_ indexPath: IndexPath) {
        let entity = getEntity(indexPath)
        let target = effectiveContext?.resolve(dataPath)
        if let entity = entity, let _ = target?.remove(&data!, entity: entity) {
            _ = target?.remove(&tableData!, entity: entity)
            if group.isEmpty {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            } else {
                let sectionDelete = removeEntityFromSection(entity)
                tableView.performBatchUpdates({
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    if sectionDelete {
                        tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
                    }
                }, completion: nil)
            }
            if indexPath == selectIndexPath {
                clearSelection()
            }
            setData()
        }
    }
    
    open func setData() {
        makeOwner()
        if !dataPath.isEmpty {
            if let _ = effectiveContext?.get(dataPath) as? Set<ModelEntity> {
                effectiveContext?.set(dataPath, Set<ModelEntity>(data ?? []))
            } else {
                effectiveContext?.set(dataPath, data)
            }
        }
    }
    
    // MARK: - Refresh
    open func handleRefresh() {
        if effectiveContext?.getBool(refresh) == true {
            refreshControl = UIRefreshControl()
            refreshControl?.backgroundColor = .clear
            refreshControl?.addTarget(self, action: #selector(refreshTriggered), for: .valueChanged)
        } else {
            refreshControl = nil
        }
    }
    
    @objc
    open func refreshTriggered(_ refreshControl: UIRefreshControl) {
        refreshControl.endRefreshing()
        update()
    }
    
    // MARK: - Activity
    @IBInspectable open var activityTop: String = "#20.0"
    @IBInspectable open var activity: String = "#false" {
        didSet {
            handleActivity()
        }
    }
    open var activityControl: UIActivityIndicatorView?
    open var activityActive: Bool = false
    
    open func handleActivity() {
        if effectiveContext?.getBool(activity) == true {
            if activityControl == nil {
                activityControl = UIActivityIndicatorView(style: .white)
                activityControl!.translatesAutoresizingMaskIntoConstraints = false
                activityControl!.isHidden = true
                view.addSubview(activityControl!)
                view.addConstraint(NSLayoutConstraint(
                    item: activityControl!,
                    attribute: .centerX,
                    relatedBy: .equal,
                    toItem: view,
                    attribute: .centerX,
                    multiplier: 1.0,
                    constant: 0))
                view.addConstraint(NSLayoutConstraint(
                    item: activityControl!,
                    attribute: .topMargin,
                    relatedBy: .equal,
                    toItem: view,
                    attribute: .top,
                    multiplier: 1.0,
                    constant: CGFloat(effectiveContext?.getFloat(activityTop) ?? 0)))
                if activityActive {
                    startActivity()
                }
            }
        } else {
            activityControl?.removeFromSuperview()
            activityControl = nil
        }
    }
    
    open func startActivity() {
        activityActive = true
        if let activityIndicatorView = activityControl {
            activityIndicatorView.alpha = 0.0
            activityIndicatorView.isHidden = false
            activityIndicatorView.startAnimating()
            UIView.animate(withDuration: 0.5, animations: {
                activityIndicatorView.alpha = 1.0
            }, completion: nil)
        }
    }
    
    open func stopActivity() {
        activityActive = false
        if let activityIndicatorView = activityControl {
            UIView.animate(withDuration: 0.1, animations: {
                activityIndicatorView.alpha = 0.0
            }, completion: { (completed) in
                activityIndicatorView.isHidden = true
                activityIndicatorView.stopAnimating()
            })
        }
    }
    
    // MARK: - Search & Filtering
    private var searchController: UISearchController?
    open func handleSearch() {
        if effectiveContext?.getBool(search) == true {
            searchController = UISearchController(searchResultsController: nil)
            searchController?.searchResultsUpdater = self
            searchController?.hidesNavigationBarDuringPresentation = false
            searchController?.obscuresBackgroundDuringPresentation = false
            searchController?.searchBar.placeholder = "Search".localized
            searchController?.searchBar.delegate = self
            if !searchFilters.isEmpty {
                searchFilterValues = ["All"]
                searchFilterValues.append(contentsOf: searchFilters.multiParts.map({ (filter) -> String in
                    return filter.trimmingCharacters(in: .whitespacesAndNewlines)
                }))
                searchController?.searchBar.scopeButtonTitles = searchFilterValues.map({ (filter) -> String in
                    return filter.localized
                })
            } else {
                searchFilterValues = []
                searchController?.searchBar.scopeButtonTitles = nil
            }
            _ = searchController?.searchBar.addBottomBorder()
            navigationItem.searchController = searchController
            definesPresentationContext = true
        } else {
            navigationItem.searchController = nil
            searchController = nil
        }
    }
    
    open func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    open func searchBarIsEmpty() -> Bool {
        return searchController?.searchBar.text?.isEmpty ?? true
    }
    
    open func filterContentForSearchText(_ searchText: String) {
        if isFiltering() {
            self.searchText = searchText
        } else {
            self.searchText = ""
        }
        update()
    }
    
    open func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        update()
    }
    
    open func isFiltering() -> Bool {
        return searchController?.isActive ?? false && !searchBarIsEmpty()
    }
    
    open func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController?.searchBar.selectedScopeButtonIndex = 0
        update()
    }
    
    // MARK: - Index
    public let sectionIndex : [String] = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "#"]
    open override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if effectiveContext?.getBool(index) == true {
            return sectionIndex
        }
        return nil
    }
    
    open override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if let section = sectionNames.first(where: { (section) in
            if title == "#" {
                return section.value.matches("^\\d")
            }
            return section.value.starts(with: title)
        })?.key {
            if let index = sections.firstIndex(of: section) {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: index), at: .top, animated: true)
            }
        }
        return -1
    }
    
    // MARK: - Segue
    open func navigateTo(entity: ModelEntity?, isNew: Bool = false ) {
        _navEntity = entity
        _navEntityNew = isNew
        performSegue(withIdentifier: Model.Identifier, sender: nil)
    }
    
    override open func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let indexPath = tableView.indexPathForSelectedRow {
            _navEntity = getEntity(indexPath)
        } else {
            _navEntity = nil
        }
        guard _navEntity == nil || !isEditing else {
            return false
        }
        setEditing(false, animated: true)
        if identifier == Model.Identifier, let navEntity = _navEntity {
            return navEntity.getBool(navEnabled) == true
        }
        return true
    }
    
    override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let context = (sender as? UIView)?.effectiveContext ?? effectiveContext
        if let selectionController = segueDestinationSelectionController(segue: segue) {
            selectionController.delegate = self
            selectionController.selectionMode = .multi
            selectionController.selectionContext = context
            if selectionController.selectionPath.isEmpty {
                selectionController.selectionPath = dataPath
            }
        }
        if let navEntity = _navEntity {
            segue.destination.context(navEntity, owner: self)
            if _navEntityNew {
                segue.destination.setEditing(true, animated: false)
            }
        } else {
            segue.destination.context(context, owner: self)
        }
        if segue.destination.isInheritingEdit && isEditing {
            segue.destination.setEditing(true, animated: false)
        }
        _navEntity = nil
        _navEntityNew = false
    }
    
    // MARK: - Invalidation
    override open func refresh(_ entity: ModelEntity, key: String? = nil, owner: UIViewController?) -> Bool {
        let contexts = context?.resolve(path: contextPath, subPath: dataPath)
        if ((contexts?.firstIndex(where: { (entity) -> Bool in
            return entity.isUnmanaged()
        })) != nil) {
            navigationController?.popToRootViewController(animated: false)
        }
        guard contexts?.contains(entity) == true || data?.contains(entity) == true else {
            return false
        }
        updateHeader(animated: true)
        guard owner != self || effectiveContext?.getBool(forceListUpdate) == true else {
            return true
        }
        update(animated: owner == self)
        return true
    }

}
