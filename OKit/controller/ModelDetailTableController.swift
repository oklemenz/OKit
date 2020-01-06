//
//  ModelDetailTableController.swift
//  OKit
//
//  Created by Klemenz, Oliver on 27.02.19.
//  Copyright © 2020 Klemenz, Oliver. All rights reserved.
//

import Foundation
import UIKit

@objc
@objcMembers
open class ModelDetailTableController : ModelBaseTableController {

    private var _navEntity: ModelEntity?
    
    @IBInspectable open var sectionHeaders: String = "" {
        didSet {
            update()
        }
    }
    
    @IBInspectable open var sectionFooters: String = "" {
        didSet {
            update()
        }
    }
    
    @IBInspectable open var tap: String = ""
    @IBInspectable open var tapEdit: String = ""
    @IBInspectable open var accyTap: String = ""
    @IBInspectable open var accyEditTap: String = ""
    @IBInspectable open var autoDeselect: String = "#true"
    @IBInspectable open var sectionsShowDisplay: String = ""
    @IBInspectable open var sectionsShowEdit: String = ""
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = true
        tableView.allowsSelectionDuringEditing = true
    }
    
    // MARK: - Edit
    override open func updateEdit() {
        if !sectionsShowDisplay.isEmpty || !sectionsShowEdit.isEmpty {
            update(animated: false)
            return
        }
        super.updateEdit()
    }
    
    // MARK: - Table
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.context(effectiveContext, owner: self)
        cell.accessoryView?.context(effectiveContext, owner: self)
        cell.editingAccessoryView?.context(effectiveContext, owner: self)
        return cell
    }
    
    override open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override open func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    override open func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.tableView(tableView, heightForHeaderInSection: section) == 0.0 {
            return nil
        }
        if !sectionHeaders.isEmpty {
            let sectionHeaderValues = sectionHeaders.multiParts.map { (header) -> String in
                return header.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            if section < sectionHeaderValues.count {
                if !sectionHeaderValues[section].isEmpty {
                    return effectiveContext?.getString(sectionHeaderValues[section])
                }
            }
        }
        return super.tableView(tableView, titleForHeaderInSection: section)
    }
    
    override open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sectionsShowValues = (isEditing ? sectionsShowEdit : sectionsShowDisplay).multiParts
        if let sectionShow = section < sectionsShowValues.count ? sectionsShowValues[section] : nil {
            return sectionShow.isEmpty || effectiveContext?.getBool(sectionShow) == true ? UITableView.automaticDimension : 0.0
        }
        return UITableView.automaticDimension
    }
    
    override open func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if self.tableView(tableView, heightForFooterInSection: section) == 0.0 {
            return nil
        }
        if !sectionFooters.isEmpty {
            let sectionFooterValues = sectionFooters.multiParts.map { (footer) -> String in
                return footer.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            if section < sectionFooterValues.count {
                if !sectionFooterValues[section].isEmpty {
                    return effectiveContext?.getString(sectionFooterValues[section])
                }
            }
        }
        return super.tableView(tableView, titleForFooterInSection: section)
    }
    
    override open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let sectionsShowValues = (isEditing ? sectionsShowEdit : sectionsShowDisplay).multiParts
        if let sectionShow = section < sectionsShowValues.count ? sectionsShowValues[section] : nil {
            return sectionShow.isEmpty || effectiveContext?.getBool(sectionShow) == true ? UITableView.automaticDimension : 0.0
        }
        return UITableView.automaticDimension
    }
    
    override open func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.backgroundView?.backgroundColor = view.theme?.groupedBackgroundColor
        }
    }
    
    override open func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let footerView = view as? UITableViewHeaderFooterView {
            footerView.backgroundView?.backgroundColor = view.theme?.groupedBackgroundColor
        }
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        if effectiveContext?.getBool(autoDeselect) == true {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        if isEditing {
            textFieldBecomeFirstResponder(indexPath: indexPath)
        } else {
            if !tap.isEmpty {
                onTap(indexPath: indexPath)
            }
        }
    }
    
    override open func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        onAccessoryTap(indexPath: indexPath)
    }
    
    open func onTap(indexPath: IndexPath) {
        let path = isEditing ? (!tapEdit.isEmpty ? tapEdit : tap) : tap
        if !path.isEmpty {
            makeOwner()
            effectiveContext?.call(path)
        }
    }
    
    open func onAccessoryTap(indexPath: IndexPath) {
        let path = isEditing ? (!accyEditTap.isEmpty ? accyEditTap : accyTap) : accyTap
        if !path.isEmpty {
            makeOwner()
            effectiveContext?.call(path)
        }
    }
    
}
