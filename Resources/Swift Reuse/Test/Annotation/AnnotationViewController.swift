//
//  Swift Reuse CodeController.h
//  Swift Reuse Code
//
//  Created by Oliver Klemenz on 25.07.14.
//
//

//
//  Swift Reuse CodeController.m
//  Swift Reuse Code
//
//  Created by Oliver Klemenz on 25.07.14.
//
//

import Foundation
import MobileCoreServices
import UIKit

class AnnotationViewController: UITableViewController, AnnotationHandlerDelegate {
    var dataSource: (NSObject & AnnotationDataSource)?
    var imageDataSource: (NSObject & ImageAnnotationDataSource)?
    var showNewDialog = false

    @objc func showNewAnnotation() {
        annotations = []

        // Write Text
        annotations.append([
        "title": "Write text".localized,
        "type": NSNumber(value: 0),
        "new": NSNumber(value: true)
        ])

        // Take Photo
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            annotations.append([
            "title": "Take Photo".localized,
            "type": NSNumber(value: 1),
            "new": NSNumber(value: true)
            ])
        }

        // Take Photo and Crop
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            annotations.append([
            "title": "Take Photo and Crop".localized,
            "type": NSNumber(value: 2),
            "new": NSNumber(value: true),
            "crop": NSNumber(value: true)
            ])
        }

        // Choose Photo
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            annotations.append([
            "title": "Choose Photo".localized,
            "type": NSNumber(value: 3),
            "new": NSNumber(value: false)
            ])
        }

        // Choose Photo and Crop
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            annotations.append([
            "title": "Choose Photo and Crop".localized,
            "type": NSNumber(value: 4),
            "new": NSNumber(value: false),
            "crop": NSNumber(value: true)
            ])
        }

        // Draw Picture
        annotations.append([
        "title": "Draw Picture".localized,
        "type": NSNumber(value: 1),
        "new": NSNumber(value: true)
        ])

        // Record Audio
        annotations.append([
        "title": "Record Audio".localized,
        "type": NSNumber(value: 2),
        "new": NSNumber(value: true)
        ])

        // Record Video
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let videoPicker = UIImagePickerController()
            let sourceTypes = UIImagePickerController.availableMediaTypes(for: videoPicker.sourceType)
            if sourceTypes?.contains(kUTTypeMovie as String) ?? false {
                annotations.append([
                "title": "Record Video".localized,
                "type": NSNumber(value: 5),
                "new": NSNumber(value: true)
                ])
            }
        }

        // Choose Video
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            annotations.append([
            "title": "Choose Video".localized,
            "type": NSNumber(value: 5),
            "new": NSNumber(value: false)
            ])
        }

        let alert = UIAlertController(title: "New Annotation".localized, message: nil, preferredStyle: .actionSheet)

        for annotation in annotations as? [[AnyHashable : Any]] ?? [] {
            let annotationHandler: ((_ action: UIAlertAction?) -> Void)? = { action in
                    self.annotationHandler = AnnotationHandler(annotationType: 0, presenter: self)
                    self.annotationHandler?.delegate = self
                    self.annotationHandler?.dataSource = self.dataSource
                    self.annotationHandler?.imageDataSource = self.imageDataSource
                if (annotation["new"] as? NSNumber)!.boolValue {
                    self.annotationHandler?.create((annotation["crop"] as? NSNumber)!.boolValue)
                    } else {
                    self.annotationHandler?.choose((annotation["crop"] as? NSNumber)!.boolValue)
                    }
                }
            let action = UIAlertAction(title: annotation["title"] as? String, style: .default, handler: annotationHandler)
            alert.addAction(action)
        }

        let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: { action in
            })

        alert.addAction(cancel)
    }

    func showAnnotation(_ uuid: String?) {
        refreshData(nil)
    }

    private var annotationHandler: AnnotationHandler?
    private var annotations: [Any] = []
    private var aggregation = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Annotations".localized
        aggregation = "annotation"

        clearsSelectionOnViewWillAppear = true
        tableView.allowsSelectionDuringEditing = true

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(AnnotationViewController.newPressed(_:)))
        navigationItem.rightBarButtonItems = [editButtonItem, addButton]

        let refresh = UIRefreshControl()
        refresh.tintColor = UIColor.black
        refresh.attributedTitle = NSAttributedString(string: "Pull to Refresh".localized)
        refresh.addTarget(self, action: #selector(AnnotationViewController.refreshData(_:)), for: .valueChanged)
        refreshControl = refresh
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if showNewDialog {
            showNewDialog = false
            perform(#selector(AnnotationViewController.showNewAnnotation), with: nil, afterDelay: 0.1)
        }
    }

    @objc func newPressed(_ sender: Any?) {
        showNewAnnotation()
    }

    func didAddAnnotation(_ data: Data?, thumbnail: Data?, length: CGFloat, sender: Any?) {
        var parameters: [String:Any]? = nil
        if let data = data {
            parameters = [
            "type": NSNumber(value: 0),
            "data": data,
            "length": NSNumber(value: Float(length))
        ]
        }
        if thumbnail != nil {
            if let thumbnail = thumbnail {
                parameters?["thumbnail"] = thumbnail
            }
        }
        let indexPath: IndexPath? = nil
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath!], with: .automatic)
        tableView.endUpdates()
    }

    func didUpdateAnnotation(_ data: Data?, thumbnail: Data?, length: CGFloat, sender: Any?) {
        let annotation: Annotation? = nil
        if annotation != nil {
            var parameters: [String:Any?]? = nil
            if let data = data {
                parameters = [
                "data": data,
                "length": NSNumber(value: Float(length))
            ]
            }
            if thumbnail != nil {
                parameters?["thumbnail"] = thumbnail
            }
            refreshSelectedCell()
        }
    }

    func didFinish() {
        let selectedIndexPath: IndexPath? = tableView.indexPathForSelectedRow
        if selectedIndexPath != nil {
            if let selectedIndexPath = selectedIndexPath {
                tableView.deselectRow(at: selectedIndexPath, animated: true)
            }
        }
    }

    func refreshSelectedCell() {
        tableView.beginUpdates()
        let selectedIndexPath: IndexPath? = tableView.indexPathForSelectedRow
        if selectedIndexPath != nil {
            tableView.reloadRows(at: [selectedIndexPath!], with: .none)
        }
        tableView.endUpdates()
        if selectedIndexPath != nil {
            tableView.selectRow(at: selectedIndexPath, animated: false, scrollPosition: .none)
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    static let tableViewCellIdentifier = "CellIdentifier"

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: AnnotationViewController.tableViewCellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: AnnotationViewController.tableViewCellIdentifier)
        }

        let annotation: Annotation? = nil
        cell?.imageView?.image = annotation?.iconImage()
        cell?.textLabel?.text = annotation?.title()
        cell?.detailTextLabel?.text = annotation?.subTitle()

        if annotation?.type == 0 {
            cell?.textLabel?.minimumScaleFactor = 8.0 / (cell?.textLabel?.font.pointSize ?? 0.0)
            cell?.textLabel?.adjustsFontSizeToFitWidth = true
        } else {
            cell?.textLabel?.minimumScaleFactor = 0.0
            cell?.textLabel?.adjustsFontSizeToFitWidth = false
        }

        var reminderActive: Bool? = nil
        if let reminderFireDate = annotation?.reminderFireDate {
            reminderActive = annotation?.reminderFireDate != nil && Date().compare(reminderFireDate) == .orderedAscending
        }

        var image: UIImage? = nil
        if reminderActive ?? false {
            image = UIImage(named: "reminder_show")
        } else {
            image = UIImage(named: "reminder_show")
        }
        let frame = CGRect(x: 0.0, y: 0.0, width: image?.size.width ?? 0.0, height: image?.size.height ?? 0.0)
        let button = UIButton(frame: frame)
        button.setBackgroundImage(image, for: .normal)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AnnotationViewController.didTapReminder(_:)))
        button.addGestureRecognizer(tapGesture)
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(AnnotationViewController.didLongPressReminder(_:)))
        button.addGestureRecognizer(longPressGesture)
        button.backgroundColor = UIColor.clear
        cell?.accessoryView = button

        return cell!
    }

    @objc func didTapReminder(_ gesture: UITapGestureRecognizer?) {
        let location: CGPoint? = gesture?.location(in: view)
        if view.convert(tableView.frame, from: tableView.superview).contains(location!) {
            let locationInTableview = tableView.convert(location ?? CGPoint.zero, from: view)
            let indexPath: IndexPath? = tableView.indexPathForRow(at: locationInTableview)
            if indexPath != nil {
                if let indexPath = indexPath {
                    tableView(tableView, accessoryButtonTappedForRowWith: indexPath)
                }
            }
        }
    }

    @objc func didLongPressReminder(_ gesture: UILongPressGestureRecognizer?) {
        let location: CGPoint? = gesture?.location(in: view)
        if view.convert(tableView.frame, from: tableView.superview).contains(location!) {
            let locationInTableview = tableView.convert(location ?? CGPoint.zero, from: view)
            let indexPath: IndexPath? = tableView.indexPathForRow(at: locationInTableview)
            if indexPath != nil {
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                let annotation: Annotation? = nil
                if annotation != nil {
                    annotation?.unscheduleReminder()
                    refreshSelectedCell()
                }
            }
        }
    }

    func didChangeReminder(_ reminderDate: Date?, offset: DateComponents?, annotation: Annotation?, sender: Any?) {
        refreshSelectedCell()
    }

    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        annotationHandler = AnnotationHandler(annotationType: 0, presenter: self)
        annotationHandler?.delegate = self
        annotationHandler?.dataSource = dataSource
        annotationHandler?.imageDataSource = imageDataSource
        annotationHandler?.editing = isEditing
    }

    @objc func refreshData(_ sender: Any?) {
        if refreshControl != nil {
            refreshControl?.endRefreshing()
        }
        tableView.reloadData()
    }
}
