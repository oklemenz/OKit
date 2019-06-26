//
//  TileViewController.swift
//  Swift Reuse Code
//
//  Created by Oliver Klemenz on 01.05.14.
//
//

import QuartzCore
import UIKit

class TileViewController: UIViewController {
    private var _positioned = false
    var positioned: Bool {
        get {
            return _positioned
        }
        set(positioned) {
            _positioned = positioned
            dataSource?.setTilePositioned(self.positioned)
        }
    }

    private var _row: Int = 0
    var row: Int {
        get {
            return _row
        }
        set(row) {
            _row = row
            dataSource?.setTileRow(self.row)
        }
    }

    private var _column: Int = 0
    var column: Int {
        get {
            return _column
        }
        set(column) {
            _column = column
            dataSource?.setTileColumn(self.column)
        }
    }
    var marked = false
    weak var dataSource: TileViewControllerDataSource?

    init(dataSource: TileViewControllerDataSource?) {
        super.init(nibName: nil, bundle: nil)
        self.dataSource = dataSource
        positioned = self.dataSource?.tilePositioned() ?? false
        row = self.dataSource?.tileRow() ?? 0
        column = self.dataSource?.tileColumn() ?? 0
        let contentRect = CGRect(x: CGFloat(ITEM_WIDTH_PADDING), y: CGFloat(ITEM_HEIGHT_PADDING), width: CGFloat(ITEM_WIDTH - 2 * ITEM_WIDTH_PADDING), height: CGFloat(ITEM_HEIGHT - 2 * ITEM_HEIGHT_PADDING))

        image = UIImageView(image: self.dataSource?.tileImage())
        image?.layer.cornerRadius = contentRect.size.width / 2.0
        image?.layer.masksToBounds = true
        image?.frame = CGRect(x: CGFloat(Double(contentRect.origin.x) + ITEM_IMAGE_PADDING), y: CGFloat(Double(contentRect.origin.y) + ITEM_IMAGE_PADDING), width: CGFloat(Double(contentRect.size.width) - 2 * ITEM_IMAGE_PADDING), height: CGFloat(Double(contentRect.size.width) - 2 * ITEM_IMAGE_PADDING))
        if let image = image {
            view.addSubview(image)
        }

        if self.dataSource?.tileShowNameInitials() ?? false {
            if initialsTextLabel == nil {
                initialsTextLabel = UILabel(frame: CGRect.zero)
                initialsTextLabel?.textAlignment = .center
                initialsTextLabel?.backgroundColor = UIColor.clear
                initialsTextLabel?.numberOfLines = 1
                initialsTextLabel?.textColor = UIColor.white
                initialsTextLabel?.font = UIFont.systemFont(ofSize: 65.0)
                initialsTextLabel?.frame = image?.frame ?? CGRect.zero
            }
            initialsTextLabel?.text = Utilities.nameInitials(self.dataSource?.tileName())
            if let initialsTextLabel = initialsTextLabel {
                view.addSubview(initialsTextLabel)
            }
        }

        label = UILabel(frame: CGRect(x: contentRect.origin.x, y: CGFloat(ITEM_WIDTH - 1.5 * ITEM_WIDTH_PADDING), width: contentRect.size.width, height: 60))
        label?.text = self.dataSource?.tileName()
        label?.textAlignment = .center
        label?.numberOfLines = 2
        label?.font = UIFont.boldSystemFont(ofSize: 25.0)
        label?.backgroundColor = UIColor.clear
        if let label = label {
            view.addSubview(label)
        }
    }

    func tileImage() -> UIImage? {
        return dataSource?.tileImage()
    }

    func adjustPosition() {
        view.frame = CGRect(x: CGFloat(Double(tileLayoutView?.origin.x ?? 0.0) + Double(column) * ITEM_WIDTH), y: CGFloat(Double(tileLayoutView?.origin.y ?? 0.0) + Double(row) * ITEM_HEIGHT), width: CGFloat(ITEM_WIDTH), height: CGFloat(ITEM_HEIGHT))
    }


    private var tileLayoutView: TileLayoutView? {
        return view.superview as? TileLayoutView
    }
    private var image: UIImageView?
    private var initialsTextLabel: UILabel?
    private var label: UILabel?
    private var longPressGestureRecognizer: UILongPressGestureRecognizer?
    private var panGestureRecognizer: UIPanGestureRecognizer?
    private var inMove = false
    private var refPoint = CGPoint.zero

    override func viewDidLoad() {
        super.viewDidLoad()
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(TileViewController.handleMove(_:)))
        if let longPressGestureRecognizer = longPressGestureRecognizer {
            view.addGestureRecognizer(longPressGestureRecognizer)
        }
    }

    func mark(_ mark: Bool, duration: CGFloat, completion: @escaping (_ finished: Bool) -> Void) {
        if mark && !marked {
            marked = true
            view.layer.zPosition = 1.0
            UIView.animate(withDuration: TimeInterval(duration / 3.0), delay: 0, options: .curveLinear, animations: {
                self.view.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                self.view.alpha = 0.5
            }) { finished in
                UIView.animate(withDuration: TimeInterval(duration / 1.5), delay: 0, options: .curveLinear, animations: {
                    self.view.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                }) { finished in
                    completion(true)
                }
            }
        } else if !mark && marked {
            marked = false
            UIView.animate(withDuration: TimeInterval(duration), delay: 0, options: .curveLinear, animations: {
                self.view.transform = .identity
                self.view.alpha = 1.0
                self.adjustPosition()
            }) { finished in
                self.view.layer.zPosition = 0.0
                completion(true)
            }
        }
    }

    @objc func handleMove(_ gestureRecognizer: UIGestureRecognizer?) {
        if gestureRecognizer?.state == .began {
            startMove(gestureRecognizer)
        } else if gestureRecognizer?.state == .changed && inMove {
            changeMove(gestureRecognizer)
        } else if gestureRecognizer?.state == .ended && inMove {
            endMove(gestureRecognizer)
        }
    }

    func startMove(_ gestureRecognizer: UIGestureRecognizer?) {
        inMove = true
        refPoint = gestureRecognizer?.location(in: view.superview) ?? CGPoint.zero
        mark(true, duration: 0.3) { _ in }
    }

    func changeMove(_ gestureRecognizer: UIGestureRecognizer?) {
        let point: CGPoint? = gestureRecognizer?.location(in: view.superview)
        var moveCenter: CGPoint = view.center
        moveCenter.x += (point?.x ?? 0.0) - refPoint.x
        moveCenter.y += (point?.y ?? 0.0) - refPoint.y
        view.center = moveCenter
        refPoint = point ?? CGPoint.zero

        tileLayoutView?.scrollRectToVisibleCentered(view.frame, animated: true)

        for tile in tileLayoutView?.tiles as? [TileViewController] ?? [] {
            if !tile.view.frame.contains(refPoint) && tile != self {
                tile.mark(false, duration: 0.2) { _ in }
            }
        }
        for tile in tileLayoutView?.tiles as? [TileViewController] ?? [] {
            if tile.view.frame.contains(refPoint) && tile != self && tile.positioned {
                tile.mark(true, duration: 0.5) { finished in
                    if tile.view.frame.contains(self.refPoint) && self.inMove {
                        let tmpColumn: Int = self.column
                        let tmpRow: Int = self.row
                        let tmpPositioned: Bool = self.positioned
                        self.column = tile.column
                        self.row = tile.row
                        self.positioned = tile.positioned
                        tile.column = tmpColumn
                        tile.row = tmpRow
                        tile.positioned = tmpPositioned
                        tile.mark(false, duration: 0.1) { _ in }
                        UIView.animate(withDuration: 1.0, animations: {
                            tile.adjustPosition()
                        })
                    } else {
                        tile.mark(false, duration: 0.2) { _ in }
                    }
                }
                break
            }
        }
    }

    func endMove(_ gestureRecognizer: UIGestureRecognizer?) {
        inMove = false
        refPoint = gestureRecognizer?.location(in: view.superview) ?? CGPoint.zero
        var found = false
        for tile in tileLayoutView?.tiles as? [TileViewController] ?? [] {
            if tile.view.frame.contains(refPoint) && tile != self {
                found = true
            }
        }
        if !found {
            if tileLayoutView?.isPointValid(refPoint) ?? false {
                positioned = tileLayoutView?.isPointPositioned(refPoint) ?? false
                row = tileLayoutView?.row(for: refPoint) ?? 0
                column = tileLayoutView?.column(for: refPoint) ?? 0
            }
        }
        mark(false, duration: 0.2) { _ in }
        tileLayoutView?.scrollRectToVisibleCentered(view.frame, animated: true)
        tileLayoutView?.didChange()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
