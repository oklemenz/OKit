//
//  ImageAnnotationViewController.swift
//  Swift Reuse Code
//
//  Created by Oliver Klemenz on 31.07.14.
//
//
import Foundation
import UIKit

let kImageAnnotationDefaultColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
let kImageAnnotationMaxUndo = 50
let kImageAnnotationMaxHistoryPencilStyle = 50

let kImageAnnotationDefaultPencilStyle = PencilStyle(color: kImageAnnotationDefaultColor, width: 3.0, alpha: 1.0)

protocol ImageAnnotationDataSource: class {
    func pencilStyles() -> [Any]?
    func add(_ pencilStyle: PencilStyle?)
}

protocol ImageAnnotationViewControllerDelegate: NSObjectProtocol {
    func didFinishDrawing(_ image: UIImage?, updated: Bool)
}

class ImageAnnotationViewController: UIViewController, PencilStyleViewDelegate {
    weak var delegate: ImageAnnotationViewControllerDelegate?
    weak var dataSource: ImageAnnotationDataSource?

    func image(_ image: UIImage?) {
        updateMode = true
        editImage = image
    }

    private var updateMode = false
    private var settingsButton: UIButton?
    private var settingsButtonItem: UIBarButtonItem?
    private var cancelButton: UIBarButtonItem?
    private var doneButton: UIBarButtonItem?
    private var undoButton: UIBarButtonItem?
    private var clearButton: UIBarButtonItem?
    private var penErasorButton: UIBarButtonItem?
    private var drawModeButtonItem: UIBarButtonItem?
    private var drawModeButton: UISegmentedControl?
    private var editImage: UIImage?
    private var imageView: UIImageView?
    private var drawImageView: UIImageView?
    private var undoImages: [AnyHashable] = []
    private var historyView: UIView?
    private var pencilStyle: PencilStyle?
    private var drawPencilStyle: PencilStyle?
    private var erasePencilStyle: PencilStyle?
    private var location = CGPoint.zero
    private var undoCrop = false

    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    init(image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        self.image(image)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white

        drawPencilStyle = PencilStyle(color: kImageAnnotationDefaultColor, width: 3.0, alpha: 1.0)
        if (dataSource?.pencilStyles()?.count ?? 0) > 0 {
            drawPencilStyle = dataSource?.pencilStyles()?[0] as? PencilStyle
        }
        pencilStyle = drawPencilStyle

        settingsButton = UIButton(type: .custom)
        settingsButton?.bounds = CGRect(x: 0, y: 0, width: CGFloat(kPencilStyleMaxWidth), height: CGFloat(kPencilStyleMaxWidth))
        settingsButton?.layer.cornerRadius = 5.0
        settingsButton?.layer.masksToBounds = true
        settingsButton?.layer.borderWidth = 1.0
        settingsButton?.layer.borderColor = UIColor.lightGray.cgColor
        if let settingsButton = settingsButton {
            settingsButtonItem = UIBarButtonItem(customView: settingsButton)
        }

        updateSettingsButton()

        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(ImageAnnotationViewController.cancel))
        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ImageAnnotationViewController.done))
        undoButton = UIBarButtonItem(barButtonSystemItem: .undo, target: self, action: #selector(ImageAnnotationViewController.undo))
        clearButton = UIBarButtonItem(title: "Clear".localized, style: .plain, target: self, action: #selector(ImageAnnotationViewController.clear))
        undoButton?.isEnabled = false

        let segItemsArray = [UIImage(named: "pencil"), UIImage(named: "eraser")]
        drawModeButton = UISegmentedControl(items: segItemsArray as [Any])
        drawModeButton?.frame = CGRect(x: 0, y: 0, width: 70, height: 30)
        drawModeButton?.selectedSegmentIndex = 0
        if let drawModeButton = drawModeButton {
            drawModeButtonItem = UIBarButtonItem(customView: drawModeButton)
        }
        drawModeButton?.addTarget(self, action: #selector(ImageAnnotationViewController.switchDrawMode(_:)), for: .valueChanged)

        navigationItem.rightBarButtonItems = ([
            doneButton,
            settingsButtonItem,
            drawModeButtonItem,
            undoButton,
            clearButton
            ] as! [UIBarButtonItem])

        imageView = UIImageView(frame: view.bounds)
        imageView?.backgroundColor = UIColor.white
        if let imageView = imageView {
            view.addSubview(imageView)
        }
        drawImageView = UIImageView(frame: view.bounds)
        drawImageView?.image = nil
        if let drawImageView = drawImageView {
            view.addSubview(drawImageView)
        }

        undoImages = []
    }

    @objc func switchDrawMode(_ segmentedControl: UISegmentedControl?) {
        if segmentedControl?.selectedSegmentIndex == 0 {
            pencilStyle = drawPencilStyle
        } else {
            pencilStyle = PencilStyle(color: UIColor.white, width: drawPencilStyle?.width ?? 0.0, alpha: drawPencilStyle?.alpha ?? 0.0)
        }
        dataSource?.add(drawPencilStyle)
    }

    func updateSettingsButton() {
        let pencilStyleView = PencilStyleView(pencilStyle: drawPencilStyle)
        settingsButton?.setImage(pencilStyleView.icon(), for: .normal)
        settingsButton?.addTarget(self, action: #selector(ImageAnnotationViewController.settings), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        if editImage != nil {
            UIGraphicsBeginImageContextWithOptions(imageView?.frame.size ?? CGSize.zero, _: false, _: 0)
            editImage?.draw(in: center(imageView?.frame ?? CGRect.zero, size: editImage?.size ?? CGSize.zero))
            imageView?.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
    }

    func center(_ rect: CGRect, size: CGSize) -> CGRect {
        let topOffset: CGFloat = (navigationController?.navigationBar.frame.size.height ?? 0.0) + UIApplication.shared.statusBarFrame.size.height
        let bottomOffset: CGFloat? = tabBarController?.tabBar.frame.size.height
        let rectSize = CGSize(width: rect.size.width, height: rect.size.height - topOffset - (bottomOffset ?? 0.0))
        let ratio = CGFloat(fmin(Float(rectSize.width / size.width), Float(rectSize.height / size.height)))
        let newRect = CGRect(x: rect.origin.x, y: rect.origin.y, width: size.width * ratio, height: size.height * ratio)
        let offsetX: CGFloat = (rectSize.width - newRect.size.width) / 2.0
        let offsetY: CGFloat = (rectSize.height - newRect.size.height) / 2.0
        return CGRect(x: rect.origin.x + offsetX, y: rect.origin.y + offsetY + topOffset, width: newRect.size.width, height: newRect.size.height)
    }

    @objc func settings() {
        togglePencilStyleHistory()
    }

    func togglePencilStyleHistory() {
        showPencilStyleHistory(historyView == nil, animated: true)
    }

    func showPencilStyleHistory(_ show: Bool, animated: Bool) {
        if historyView == nil && show {
            historyView = UIView(frame: view.bounds)
            historyView?.backgroundColor = UIColor.clear
            historyView?.isUserInteractionEnabled = true
            UIGraphicsBeginImageContextWithOptions(view.bounds.size, _: false, _: 0)
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
            let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            let blurImageView = UIImageView(frame: view.bounds)
            blurImageView.image = image

            historyView?.addSubview(blurImageView)

            UIGraphicsBeginImageContextWithOptions(view.bounds.size, _: false, _: 0.0)
            let blank: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            let rasterView = UIImageView(frame: view.bounds)
            rasterView.image = blank
            rasterView.backgroundColor = UIColor(patternImage: UIImage(named: "raster")!)
            rasterView.alpha = 0.5
            historyView?.addSubview(rasterView)

            let offset = CGPoint(x: 0, y: (navigationController?.navigationBar.frame.size.height ?? 0.0) + UIApplication.shared.statusBarFrame.size.height)

            let newPencilStyle = UIButton(frame: CGRect(x: offset.x, y: offset.y, width: CGFloat(kPencilStyleGrid), height: CGFloat(kPencilStyleGrid)))
            newPencilStyle.contentHorizontalAlignment = .center
            newPencilStyle.contentVerticalAlignment = .center
            newPencilStyle.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12.0)
            newPencilStyle.setTitleColor(UIColor(red: 0.0, green: 122.0 / 255.0, blue: 1.0, alpha: 1.0), for: .normal)
            newPencilStyle.addTarget(self, action: #selector(ImageAnnotationViewController.didTapNewPencilStyle(_:)), for: .touchUpInside)
            newPencilStyle.setTitle("New".localized, for: .normal)
            historyView?.addSubview(newPencilStyle)

            let width: CGFloat = view.bounds.size.width
            let height: CGFloat = view.bounds.size.height
            let columnCount = Int(floor(width / CGFloat(kPencilStyleGrid)))
            let rowCount = Int(floor(height / CGFloat(kPencilStyleGrid)))


            UIGraphicsBeginImageContext(rasterView.frame.size)
            rasterView.image?.draw(in: rasterView.frame)

            let context = UIGraphicsGetCurrentContext()
            context?.setAllowsAntialiasing(false)

            context?.setStrokeColor(UIColor(white: 0.5, alpha: 1.0).cgColor)
            context?.setLineWidth(1.0)
            let dashLengths = [CGFloat(10), CGFloat(5)]
            context?.setLineDash(phase: 0, lengths: dashLengths)

            for i in 0..<columnCount {
                context?.move(to: CGPoint(x: CGFloat((i + 1) * kPencilStyleGrid), y: 0))
                context?.addLine(to: CGPoint(x: CGFloat((i + 1) * kPencilStyleGrid), y: height))
                context?.strokePath()
            }
            for j in 0..<rowCount {
                context?.move(to: CGPoint(x: 0, y: offset.y + CGFloat((j + 1) * kPencilStyleGrid)))
                context?.addLine(to: CGPoint(x: width, y: offset.y + CGFloat((j + 1) * kPencilStyleGrid)))
                context?.strokePath()
            }

            rasterView.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            var row: Int = 0
            var column: Int = 1
            for pencilStyle in dataSource?.pencilStyles() as? [PencilStyle] ?? [] {
                let pencilStyleView = PencilStyleView(pencilStyle: pencilStyle)
                pencilStyleView.delegate = self
                pencilStyleView.position(row, column: column, offset: offset)
                historyView?.addSubview(pencilStyleView)
                column += 1
                if column >= columnCount {
                    row += 1
                    column = 0
                }
            }

            if animated {
                historyView?.alpha = 0.0
                UIView.animate(withDuration: 0.5, animations: {
                    self.historyView?.alpha = 1.0
                })
            } else {
                historyView?.alpha = 1.0
            }

            if let historyView = historyView {
                view.addSubview(historyView)
            }
            enabledButtons(false)
        } else if historyView != nil && !show {
            if animated {
                UIView.animate(withDuration: 0.5, animations: {
                    self.enabledButtons(true)
                    self.historyView?.alpha = 0.0
                }) { finished in
                    self.historyView?.removeFromSuperview()
                    self.historyView = nil
                }
            } else {
                historyView?.alpha = 0.0
                historyView?.removeFromSuperview()
                historyView = nil
                enabledButtons(true)
            }
        }
    }

    func select(_ pencilStyle: PencilStyle?, animated: Bool) {
        drawPencilStyle = pencilStyle
        dataSource?.add(pencilStyle)
        switchDrawMode(drawModeButton)
        updateSettingsButton()
        showPencilStyleHistory(false, animated: animated)
    }

    func didSelectPencilStyle(_ pencilStyleView: PencilStyleView?) {
        select(pencilStyleView?.pencilStyle, animated: true)
    }

    func didMarkPencilStyle(_ pencilStyleView: PencilStyleView?) {
        edit(pencilStyleView?.pencilStyle)
    }

    @objc func didTapNewPencilStyle(_ gestureRecognizer: UITapGestureRecognizer?) {
        edit(drawPencilStyle)
    }

    func edit(_ pencilStyle: PencilStyle?) {
    }

    func enabledButtons(_ enabled: Bool) {
        if enabled {
            navigationItem.leftBarButtonItem = navigationItem.backBarButtonItem
        } else if !enabled {
            navigationItem.leftBarButtonItem = cancelButton
        }
        doneButton?.isEnabled = enabled
        undoButton?.isEnabled = enabled
        clearButton?.isEnabled = enabled
        drawModeButton?.isEnabled = enabled
        drawModeButtonItem?.isEnabled = enabled
        drawModeButton?.isUserInteractionEnabled = enabled
        if enabled {
            enabledUndoButton()
        }
    }

    func didChangeSettings(_ pencilStyle: PencilStyle?, sender: Any?) {
        select(pencilStyle, animated: false)
    }

    @objc func undo() {
        if undoImages.count > 0 {
            let undoImage = undoImages.last as? UIImage
            if undoImage != nil {
                imageView?.image = undoImage
            }
            undoImages.removeLast()
        } else if !undoCrop {
            imageView?.image = nil
        }
        enabledUndoButton()
    }

    func enabledUndoButton() {
        undoButton?.isEnabled = undoImages.count > 0 || (imageView?.image != nil && !undoCrop)
    }

    @objc func cancel() {
        showPencilStyleHistory(false, animated: true)
    }

    @objc func done() {
        let topOffset: CGFloat = (navigationController?.navigationBar.frame.size.height ?? 0.0) + UIApplication.shared.statusBarFrame.size.height
        let bottomOffset: CGFloat? = tabBarController?.tabBar.frame.size.height

        let rect = CGRect(x: view.bounds.origin.x, y: view.bounds.origin.y - topOffset, width: view.bounds.size.width, height: view.bounds.size.height)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: rect.size.width, height: rect.size.height - topOffset - (bottomOffset ?? 0.0)), _: false, _: 0)
        view.drawHierarchy(in: rect, afterScreenUpdates: true)
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        delegate?.didFinishDrawing(image, updated: updateMode)
    }

    @objc func clear() {
        _ = Common.showConfirmation(self, title: "Clear drawing".localized, message: "Do you want to clear all?".localized, okButtonTitle: nil, destructive: false, okHandler: {
            self.addUndo()
            self.imageView?.image = nil
        }, cancelHandler: {  })
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if historyView != nil {
            return
        }
        let touch = touches.first
        location = touch?.location(in: imageView) ?? CGPoint.zero
        touchesMoved(touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if historyView != nil {
            return
        }
        let touch = touches.first
        let currentLocation: CGPoint? = touch?.location(in: view)
        UIGraphicsBeginImageContext(view.frame.size)
        drawImageView?.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))

        let context = UIGraphicsGetCurrentContext()
        context?.move(to: CGPoint(x: location.x, y: location.y))
        context?.addLine(to: CGPoint(x: currentLocation?.x ?? 0.0, y: currentLocation?.y ?? 0.0))
        context!.setLineCap(CGLineCap.round)
        context?.setLineWidth(pencilStyle?.width ?? 0.0)
        if let cg = pencilStyle?.color?.cgColor {
            context?.setStrokeColor(cg)
        }
        context!.setBlendMode(CGBlendMode.normal)
        context?.strokePath()

        drawImageView?.image = UIGraphicsGetImageFromCurrentImageContext()
        drawImageView?.alpha = pencilStyle?.alpha ?? 0.0
        UIGraphicsEndImageContext()

        location = currentLocation ?? CGPoint.zero
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if historyView != nil {
            return
        }
        addUndo()
        UIGraphicsBeginImageContext((imageView?.frame.size)!)
        imageView?.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: .normal, alpha: 1.0)
        drawImageView?.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: .normal, alpha: pencilStyle?.alpha ?? 0.0)
        imageView?.image = UIGraphicsGetImageFromCurrentImageContext()
        drawImageView?.image = nil
        UIGraphicsEndImageContext()
    }

    func addUndo() {
        if imageView?.image != nil {
            if let image = imageView?.image {
                undoImages.append(image)
            }
        }
        undoButton?.isEnabled = true
        if undoImages.count > kImageAnnotationMaxUndo {
            undoImages.remove(at: 0)
            undoCrop = true
        }
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
