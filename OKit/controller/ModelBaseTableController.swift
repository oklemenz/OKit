//
//  ModelBaseTableController.swift
//  OKit
//
//  Created by Klemenz, Oliver on 27.03.19.
//  Copyright © 2019 Klemenz, Oliver. All rights reserved.
//

import Foundation
import UIKit

@objc
@objcMembers
open class ModelBaseTableController: ModelController, ModelSelectionDelegate {
    
    // MARK: - Context
    internal var internalContext: ModelEntity?
    override open var context: ModelEntity? {
        get {
            return internalContext ?? parent?.context ?? Model.getDefault()
        }
        set {
            internalContext = newValue
            update()
        }
    }
    
    override open func resetContext() {
        self.context = nil
        update()
    }
    
    override open func context(_ context: ModelEntity?, owner: AnyObject?) {
        self.context = context
        update()
    }
    
    open var effectiveContext: ModelEntity? {
        if !contextPath.isEmpty {
            return context?.resolve(contextPath)
        }
        return context
    }
    
    // MARK: - Inspectable
    @IBInspectable open var contextPath: String = "" {
        didSet {
            update()
        }
    }
    @IBInspectable open var promptPath: String = "" {
        didSet {
            updatePrompt()
        }
    }
    @IBInspectable open var titlePath: String = "" {
        didSet {
            updateTitle()
        }
    }
    @IBInspectable open var titleTap: String = ""
    @IBInspectable open var titleCount: String = "" {
        didSet {
            updateTitle()
        }
    }
    @IBInspectable open var subTitlePath: String = "" {
        didSet {
            updateTitle()
        }
    }
    @IBInspectable open var subTitleObject: String = "" {
        didSet {
            updateTitle()
        }
    }
    @IBInspectable open var subTitleObjectPlural: String = "" {
        didSet {
            updateTitle()
        }
    }
    @IBInspectable open var subTitleSwap: String = "#false" {
        didSet {
            updateTitle()
        }
    }
    @IBInspectable open var edit: String = "#true" {
        didSet {
            handleEdit()
        }
    }
    @IBInspectable open var editEnabled: String = "#true"
    @IBInspectable open var editInherit: String = "#false"
    @IBInspectable open var editAlways: String = "#false" {
        didSet {
            handleEditAlways()
        }
    }
    @IBInspectable open var help: String = "#true" {
        didSet {
            handleHelp()
        }
    }
    @IBInspectable open var forceUpdate: String = "#true"
    
    // MARK: - View
    open var isReady: Bool {
        return viewIfLoaded != nil && effectiveContext != nil
    }

    
    override open func viewDidLoad() {
        super.viewDidLoad()
        tableView.keyboardDismissMode = .onDrag
    }
    
    private var navBarTapGestureRecognizer: UITapGestureRecognizer?
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navBarTapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(self.navigationBarTapped(_:)))
        navBarTapGestureRecognizer?.cancelsTouchesInView = false
        if let navBarTapGestureRecognizer = navBarTapGestureRecognizer {
            navigationController?.navigationBar.addGestureRecognizer(navBarTapGestureRecognizer)
        }
        update()
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let navBarTapGestureRecognizer = navBarTapGestureRecognizer {
            navigationController?.navigationBar.removeGestureRecognizer(navBarTapGestureRecognizer)
        }
    }
    
    @objc
    open func navigationBarTapped(_ sender: UITapGestureRecognizer){
        guard !titleTap.isEmpty else {
            return
        }
        let location = sender.location(in: self.navigationController?.navigationBar)
        let hitView = self.navigationController?.navigationBar.hitTest(location, with: nil)
        guard !(hitView is UIControl) else {
            return
        }
        effectiveContext?.call(titleTap)
    }
    
    // MARK: - Setup
    override open func setup() {
        handleEdit()
        handleEditAlways()
        handleHelp()
        
        update()
    }
    
    // MARK: - Update
    override open func update(animated: Bool = false) {
        guard isReady else {
            return
        }
        tableView.context(effectiveContext, owner: self)
        updateData()
        updateUI(animated: false)
    }

    open func updateData() {
    }
    
    open func updateUI(animated: Bool = false) {
        guard isReady else {
            return
        }
        updateHeader(animated: animated)
        updateTable(animated: animated)
    }
    
    private var _inUpdateTable: Bool = false
    open func updateTable(animated: Bool = false, completion: ModelCompletion? = nil) {
        if !animated {
            self.tableView.reloadData()
        } else {
            guard !self._inUpdateTable else {
                return
            }
            self._inUpdateTable = true
            UIView.transition(with: self.tableView, duration: 0.2, options: .transitionCrossDissolve, animations: { () -> Void in
                self.tableView.reloadData()
            }, completion: { (completed) in
                self._inUpdateTable = false
                completion?(completed)
            })
        }
    }
    
    open func updateHeader(animated: Bool = false) {
        updatePrompt()
        updateTitle()
        updateBarButtonItems()
    }
    
    // MARK: - Selection
    open func didSelect(modelRef: ModelRef) {
        update()
    }
    
    open func didClearSelection(modelRef: ModelRef) {
        update()
    }
    
    // MARK: - Prompt
    open func updatePrompt() {
        navigationItem.prompt = !promptPath.isEmpty ? effectiveContext?.getString(promptPath) : nil
    }

    // MARK: - Title
    private var titleLabel: UILabel?
    open func updateTitle() {
        if !titlePath.isEmpty {
            let titleValue = self.titleValue
            if let titleValue = titleValue as? NSAttributedString {
                if titleLabel == nil {
                    titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
                    titleLabel?.backgroundColor = UIColor.clear
                    titleLabel?.numberOfLines = 2
                    titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
                    titleLabel?.textAlignment = .center
                    titleLabel?.textColor = .black
                }
                titleLabel?.attributedText = titleValue
                navigationItem.titleView = titleLabel
            } else if let titleValue = titleValue as? String {
                navigationItem.title = titleValue
                navigationItem.titleView = nil
            }
        }
    }
    
    open var titleValue: Any? {
        let separator = UIDevice.current.orientation.isLandscape ? " - " : "\n"
        if !titlePath.isEmpty {
            var titleValue: Any? = !titlePath.isEmpty ? effectiveContext?.get(titlePath) : nil
            var subTitleValue: Any? = !subTitlePath.isEmpty ? effectiveContext?.get(subTitlePath) : nil
            if titleValue != nil && !(titleValue is NSAttributedString || titleValue is String) {
                titleValue = String(describing: titleValue)
            }
            if subTitleValue != nil && !(subTitleValue is NSAttributedString || subTitleValue is String) {
                subTitleValue = String(describing: subTitleValue)
            }
            if subTitleValue == nil && !subTitleObject.isEmpty && !titleCount.isEmpty {
                let count = effectiveContext?.getInt(titleCount) ?? 0
                let object: String? = !subTitleObject.isEmpty ? effectiveContext?.getString(subTitleObject) : nil
                let objectPlural: String? = !subTitleObjectPlural.isEmpty ? effectiveContext?.getString(subTitleObjectPlural) : (object != nil ? "\(object!)s" : nil)
                subTitleValue = String(format: count == 1 ?
                    "%i\(object != nil ? " \(object!)" : "")" :
                    "%i\(objectPlural != nil ? " \(objectPlural!)" : "")", count)
            }
            if subTitleValue is String {
                subTitleValue = (subTitleValue as! String).subTitle
            }
            if titleValue != nil && subTitleValue == nil && !titleCount.isEmpty {
                let count = effectiveContext?.getInt(titleCount) ?? 0
                titleValue = "\(titleValue!) (\(count))"
            }
            if titleValue is String {
                titleValue = (titleValue as! String).title
            }
            if effectiveContext?.getBool(subTitleSwap) == true {
                swap(&titleValue, &subTitleValue)
            }
            if let titleValue = titleValue as? NSAttributedString {
                if let subTitleValue = subTitleValue as? NSAttributedString {
                    let titleAttributedString = NSMutableAttributedString(attributedString: titleValue)
                    titleAttributedString.append(separator.subTitle)
                    titleAttributedString.append(subTitleValue)
                    return titleAttributedString
                } else if let subTitleValue = subTitleValue as? String {
                    let titleAttributedString = NSMutableAttributedString(attributedString: titleValue)
                    titleAttributedString.append(separator.subTitle)
                    titleAttributedString.append(NSAttributedString(string: subTitleValue))
                    return titleAttributedString
                }
                return titleValue
            } else if let titleValue = titleValue as? String {
                if let subTitleValue = subTitleValue as? NSAttributedString {
                    let titleAttributedString = NSMutableAttributedString(string: titleValue)
                    titleAttributedString.append(separator.subTitle)
                    titleAttributedString.append(subTitleValue)
                    return titleAttributedString
                } else if let subTitleValue = subTitleValue as? String {
                    return titleValue + separator + subTitleValue
                }
                return titleValue
            } else {
                return subTitleValue
            }
        }
        return nil
    }
    
    open var titleStringValue: String? {
        let titleValue = self.titleValue
        if let titleValue = titleValue as? NSAttributedString {
            return titleValue.string
        } else if let titleValue = titleValue as? String {
            return titleValue
        }
        return nil
    }
    
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        clearSelection()
        updateUI()
    }
    
    // MARK: - Edit
    override open func setEditing(_ editing: Bool, animated: Bool) {
        guard isEditing != editing else {
            return
        }
        makeOwner()
        super.setEditing(editing, animated: animated)
        clearSelection()
        updateEdit()
    }
    
    open func updateEdit() {
        if !isEditing && tableView.allowsMultipleSelectionDuringEditing {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.update()
            }
        }
        if isEditing {
            firstTextFieldBecomeFirstResponder()
        }
    }
    
    open func handleEdit() {
        navigationItem.rightBarButtonItems = navigationItem.rightBarButtonItems ?? []
        let index = navigationItem.rightBarButtonItems!.firstIndex(of: editButtonItem)
        if effectiveContext?.getBool(edit) == true && effectiveContext?.getBool(editAlways) == false {
            if index == nil  {
                navigationItem.rightBarButtonItems!.append(editButtonItem)
            }
        } else {
            if let index = index {
                navigationItem.rightBarButtonItems!.remove(at: index)
            }
        }
    }
    
    open func handleEditAlways() {
        guard let _ = viewIfLoaded else {
            return
        }
        if effectiveContext?.getBool(editAlways) == true {
            setEditing(true, animated: false)
        }
    }
    
    override open var isInheritingEdit: Bool {
        return effectiveContext?.getBool(editInherit) == true
    }

    open func firstTextFieldBecomeFirstResponder() {
        for cell in tableView.visibleCells {
            for view in cell.contentView.subviews {
                if let textField = view as? UITextField {
                    DispatchQueue.main.async() {
                        textField.becomeFirstResponder()
                    }
                    return
                }
            }
        }
    }
    
    open func textFieldBecomeFirstResponder(indexPath: IndexPath) {
        for cell in tableView.visibleCells {
            if cell.indexPath() == indexPath {
                for view in cell.contentView.subviews {
                    if let textField = view as? UITextField {
                        DispatchQueue.main.async() {
                            textField.becomeFirstResponder()
                        }
                        return
                    }
                }
            }
        }
    }
    
    // MARK: - Selection
    open var selectIndexPath: IndexPath?
    open var selectProxyIndexPath: IndexPath?
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
        var selectProxy = false
        var effectiveIndexPath: IndexPath? = indexPath
        if let cell = super.tableView(tableView, cellForRowAt: indexPath) as? ModelTableCell {
            if !cell.selectNextRow.isEmpty, let selectNextRow = cell.effectiveContext?.getInt(cell.selectNextRow), selectNextRow != 0 {
                effectiveIndexPath = IndexPath(row: indexPath.row + selectNextRow, section: indexPath.section)
                if isValid(indexPath: effectiveIndexPath) {
                    selectProxy = true
                } else {
                    effectiveIndexPath = nil
                }
            }
        }
        if (effectiveIndexPath == selectIndexPath) {
            clearSelection()
        } else {
            selectIndexPath = effectiveIndexPath
            selectProxyIndexPath = selectProxy ? indexPath : nil
            updateSelection()
        }
    }
    
    func isValid(indexPath: IndexPath?) -> Bool {
        guard let indexPath = indexPath else {
            return false
        }
        if indexPath.section >= numberOfSections(in: tableView) {
            return false
        }
        if indexPath.row >= tableView(tableView, numberOfRowsInSection: indexPath.section) {
            return false
        }
        return true
    }
    
    open func updateSelection(completion: ModelCompletion? = nil) {
        for cell in tableView.visibleCells {
            if let modelCell = cell as? ModelEditCell {
                modelCell.selectActive = modelCell.indexPath == selectIndexPath
            }
            if let modelCell = cell as? ModelTableCell {
                modelCell.selectActiveProxy = modelCell.indexPath == selectProxyIndexPath
            }
        }
        tableView.performBatchUpdates({
        }, completion: completion)
    }
    
    open func clearSelection() {
        selectIndexPath = nil
        selectProxyIndexPath = nil
        updateSelection()
    }
    
    // MARK: - Table
    override open func configure(cell: UITableViewCell, indexPath: IndexPath) {
        if let modelCell = cell as? ModelEditCell {
            modelCell.selectActive = indexPath == selectIndexPath
        }
        if let modelCell = cell as? ModelTableCell {
            modelCell.selectActiveProxy = modelCell.indexPath == selectProxyIndexPath
        }
    }
    
    open func heightForCell(context: ModelEntity?, cell: UITableViewCell, indexPath: IndexPath) -> CGFloat? {
        if let modelCell = cell as? ModelTableCell {
            if isEditing {
                if context?.getBool(modelCell.showEdit) == false {
                    return CGFloat(0.0)
                }
                if selectIndexPath == indexPath {
                    if let height = context?.getFloat(modelCell.heightSelect) {
                        return CGFloat(height)
                    }
                }
                if let height = context?.getFloat(modelCell.heightEdit) {
                    return CGFloat(height)
                }
            }
            if context?.getBool(modelCell.showDisplay) == false {
                return CGFloat(0.0)
            }
            if let height = context?.getFloat(modelCell.heightDisplay) {
                return CGFloat(height)
            }
        }
        return nil
    }
    
    override open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let cell = tableView.cellForRow(at: indexPath) {
            if let height = heightForCell(context: effectiveContext, cell: cell, indexPath: indexPath) {
                return height
            }
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // MARK: - Bar Buttons
    open func updateBarButtonItems() {
        for barButtonItem in navigationItem.leftBarButtonItems ?? [] {
            (barButtonItem as? ModelBarButtonItem)?.context(effectiveContext, owner: self)
        }
        for barButtonItem in navigationItem.rightBarButtonItems ?? [] {
            (barButtonItem as? ModelBarButtonItem)?.context(effectiveContext, owner: self)
        }
        for barButtonItem in toolbarItems ?? [] {
            (barButtonItem as? ModelBarButtonItem)?.context(effectiveContext, owner: self)
        }
    }
    
    @objc
    open override func didTapBarButtonItem(_ barButtonItem: ModelBarButtonItem) {
        if let path = barButtonItem.accessibilityIdentifier {
            makeOwner()
            effectiveContext?.call(path, completion: { (completed) in
                self.update()
            })
        }
    }
    
    @objc
    open override func didTapButton(_ button: ModelButton) {
        if let path = button.accessibilityIdentifier {
            makeOwner()
            effectiveContext?.call(path, completion: { (completed) in
                self.update()
            })
        }
    }
    
    // MARK: - Help
    @IBOutlet open var helpView: ModelHelpView?
    private var helpBarButton: ModelBarButtonItem!
    open func handleHelp() {
        guard let _ = helpView else {
            return
        }
        navigationItem.rightBarButtonItems = navigationItem.rightBarButtonItems ?? []
        if helpBarButton == nil {
            helpBarButton = ModelBarButtonItem(title: "?".localized, style: .plain, target: self, action: #selector(onHelpTap(_:)))
            helpBarButton.managed = true
        }
        let index = navigationItem.rightBarButtonItems!.firstIndex(of: helpBarButton)
        if effectiveContext?.getBool(help) == true {
            if index == nil  {
                navigationItem.rightBarButtonItems!.append(helpBarButton)
            }
        } else {
            if let index = index {
                navigationItem.rightBarButtonItems!.remove(at: index)
            }
        }
    }
    
    @objc
    open func onHelpTap(_ barButtonItem: UIBarButtonItem) {
        helpView?.context(effectiveContext, owner: self)
        helpView?.show(owner: self)
    }
    
    // MARK: - Segue
    open func navigate() {
        performSegue(withIdentifier: Model.Identifier, sender: nil)
    }
    
    override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let context = (sender as? UIView)?.effectiveContext ?? effectiveContext
        if let selectionController = segueDestinationSelectionController(segue: segue) {
            selectionController.delegate = self
            selectionController.selectionMode = .single
            selectionController.selectionContext = context
            if selectionController.selectionPath.isEmpty {
                selectionController.selectionPath = "."
            }
        }
        segue.destination.context(context, owner: self)
        if segue.destination.isInheritingEdit && isEditing {
           segue.destination.setEditing(true, animated: false)
        }
    }
    
    open func segueDestinationSelectionController(segue: UIStoryboardSegue) -> ModelSelectionTableController? {
        if let selectionController = segue.destination as? ModelSelectionTableController {
            return selectionController as ModelSelectionTableController
        }
        if let navigationController = segue.destination as? UINavigationController {
            return navigationController.topViewController as? ModelSelectionTableController
        }
        return nil
    }

    // MARK: - Invalidation
    override open func refresh(_ entity: ModelEntity, key: String? = nil, owner: UIViewController?) -> Bool {
        let contexts = context?.resolve(path: contextPath)
        if ((contexts?.firstIndex(where: { (entity) -> Bool in
            return entity.isUnmanaged()
        })) != nil) {
            navigationController?.popToRootViewController(animated: false)
        }
        let contextsInCell = tableView.visibleCells.contains { (cell) -> Bool in
            return cell.contexts.contains(entity)
        }
        guard contexts?.contains(entity) == true || contextsInCell else {
            return false
        }
        updateHeader(animated: true)
        guard owner != self || effectiveContext?.getBool(forceUpdate) == true else {
            return true
        }
        update(animated: false)
        return true
    }
    
}
