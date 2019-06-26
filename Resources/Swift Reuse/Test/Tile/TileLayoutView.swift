//
//  TileLayoutView.swift
//  Swift Reuse Code
//
//  Created by Oliver Klemenz on 01.05.14.
//
//

import QuartzCore
import UIKit

protocol TileLayoutViewDelegate: NSObjectProtocol {
    func didChange()
}

class TileLayoutView: UIView {
    var rows: Int = 0
    var columns: Int = 0
    var itemRows: Int = 0
    var itemColumns: Int = 0
    var itemSplitRow: Int = 0
    var origin = CGPoint.zero
    var tiles: [Any] = []
    weak var delegate: TileLayoutViewDelegate?

    private var _tileDataSources: [TileViewControllerDataSource] = []
    var tileDataSources: [TileViewControllerDataSource] {
        get {
            return _tileDataSources
        }
        set(tileDataSources) {
            _tileDataSources = tileDataSources
            revalidate()
        }
    }

    func isPointValid(_ point: CGPoint) -> Bool {
        return point.x >= 0 && point.y >= 0 && Double(point.x) < Double(columns) * ITEM_WIDTH && Double(point.y) < Double(rows) * ITEM_HEIGHT
    }

    func isPointPositioned(_ point: CGPoint) -> Bool {
        if isPointValid(point) {
            let row: Int = self.row(for: point)
            return row < itemSplitRow
        }
        return false
    }

    func row(for point: CGPoint) -> Int {
        return Int(round((Double(point.y - origin.y) - 0.5 * ITEM_HEIGHT) / ITEM_HEIGHT))
    }

    func column(for point: CGPoint) -> Int {
        return Int(round((Double(point.x - origin.x) - 0.5 * ITEM_WIDTH) / ITEM_WIDTH))
    }

    func scrollRectToVisibleCentered(_ visibleRect: CGRect, animated: Bool) {
        let scrollView = superview as? UIScrollView
        let centeredRect = CGRect(x: (visibleRect.origin.x - visibleRect.size.width / 2.0) * (scrollView?.zoomScale ?? 0.0), y: (visibleRect.origin.y - visibleRect.size.height / 2.0) * (scrollView?.zoomScale ?? 0.0), width: 2 * visibleRect.size.width * (scrollView?.zoomScale ?? 0.0), height: 2 * visibleRect.size.height * (scrollView?.zoomScale ?? 0.0))
        scrollView?.scrollRectToVisible(centeredRect, animated: animated)
    }

    func revalidate() {
        for view in subviews {
            view.removeFromSuperview()
        }
        tiles.removeAll()
        for tileDelegate in tileDataSources {
            let tile = TileViewController(dataSource: tileDelegate)
            tiles.append(tile)
            addSubview(tile.view)
        }
        tiles = tiles.sorted(by: { (tile1, tile2) -> Bool in
            let tile1Name = (tile1 as? TileViewController)?.dataSource?.tileName() ?? ""
            let tile2Name = (tile2 as? TileViewController)?.dataSource?.tileName() ?? ""
            return tile1Name < tile2Name
        }) as? [AnyHashable] ?? tiles
        refresh(false)
    }

    func didChange() {
        refresh(true)
    }

    private var minItemRow: Int = 0
    private var minItemColumn: Int = 0
    private var maxItemRow: Int = 0
    private var maxItemColumn: Int = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        tiles = []
        backgroundColor = UIColor.clear
    }

    func refresh(_ animated: Bool) {
        if animated {
            calcContainerSize()
            adjustSize()
            delegate?.didChange()
            setNeedsDisplay()
            UIView.animate(withDuration: 0.5, animations: {
                self.positionTiles()
            })
        } else {
            calcContainerSize()
            adjustSize()
            delegate?.didChange()
            setNeedsDisplay()
            positionTiles()
        }
    }

    func calcContainerSize() {
        columns = 0
        rows = 0

        itemColumns = 0
        itemRows = 0

        minItemRow = BORDER_CELLS
        minItemColumn = BORDER_CELLS
        maxItemRow = BORDER_CELLS
        maxItemColumn = BORDER_CELLS

        itemSplitRow = BORDER_CELLS

        var positionedCount: Int = 0
        for tile in tiles as? [TileViewController] ?? [] {
            if tile.positioned {
                if positionedCount == 0 {
                    minItemRow = tile.row
                    minItemColumn = tile.column
                    maxItemRow = tile.row
                    maxItemColumn = tile.column
                } else {
                    minItemRow = min(tile.row, minItemRow)
                    minItemColumn = min(tile.column, minItemColumn)
                    maxItemRow = max(tile.row, maxItemRow)
                    maxItemColumn = max(tile.column, maxItemColumn)
                }
                positionedCount += 1
            }
        }

        var nonPositionedCount: Int = 0
        for tile in tiles as? [TileViewController] ?? [] {
            if !tile.positioned {
                nonPositionedCount += 1
            }
        }

        if positionedCount > 0 {
            itemColumns = maxItemColumn - minItemColumn + 1
            itemRows = maxItemRow - minItemRow + 1
            itemSplitRow += maxItemRow + 1
        }

        if nonPositionedCount > 0 {
            let nonPositionedColumns = Int(ceil(sqrt(Float(nonPositionedCount))))
            if nonPositionedColumns > itemColumns {
                itemColumns = nonPositionedColumns
            }
            let nonPositionedMaxRow = Int(ceil(Float(nonPositionedCount) / Float(itemColumns)))
            if nonPositionedMaxRow > 0 {
                itemRows += (itemRows > 0 ? BORDER_CELLS : 0) + nonPositionedMaxRow
            }
        }

        columns = itemColumns + 2 * BORDER_CELLS
        rows = itemRows + 2 * BORDER_CELLS

        origin = CGPoint(x: CGFloat(Double((BORDER_CELLS - minItemColumn)) * ITEM_WIDTH), y: CGFloat(Double((BORDER_CELLS - minItemRow)) * ITEM_HEIGHT))
    }

    func positionTiles() {
        for tile in tiles as? [TileViewController] ?? [] {
            if tile.positioned {
                tile.adjustPosition()
            }
        }
        var index: Int = 0
        for tile in tiles as? [TileViewController] ?? [] {
            if !tile.positioned {
                tile.row = itemSplitRow + index / itemColumns
                tile.column = minItemColumn + index % itemColumns
                tile.adjustPosition()
                index += 1
            }
        }
    }

    func scroll() -> UIScrollView? {
        return superview as? UIScrollView
    }

    func adjustSize() {
        bounds = CGRect(x: 0, y: 0,
                        width: max(CGFloat(columns) * CGFloat(ITEM_WIDTH), CGFloat((superview?.bounds.size.width)!)),
                        height: max(CGFloat(rows) * CGFloat(ITEM_HEIGHT), CGFloat((superview?.bounds.size.height)!)))
    }

    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setAllowsAntialiasing(false)

        context?.setStrokeColor(UIColor(white: 0.75, alpha: 1.0).cgColor)
        context?.setLineWidth(2.5)
        let dashLengths = [CGFloat(10), CGFloat(5)]
        context?.setLineDash(phase: 0, lengths: dashLengths)

        for i in 0..<columns - 1 {
            context?.move(to: CGPoint(x: CGFloat(Double((i + 1)) * ITEM_WIDTH), y: 0))
            context?.addLine(to: CGPoint(x: CGFloat(Double((i + 1)) * ITEM_WIDTH), y: rect.size.height))
            context?.strokePath()
        }
        for j in 0..<rows - 1 {
            context?.move(to: CGPoint(x: 0, y: CGFloat(Double((j + 1)) * ITEM_HEIGHT)))
            context?.addLine(to: CGPoint(x: rect.size.width, y: CGFloat(Double((j + 1)) * ITEM_HEIGHT)))
            context?.strokePath()
        }

        context?.setLineWidth(10)

        context?.move(to: CGPoint(x: 0, y: CGFloat(Double(origin.y) + Double(itemSplitRow) * ITEM_HEIGHT)))
        context?.addLine(to: CGPoint(x: rect.size.width, y: CGFloat(Double(origin.y) + Double(itemSplitRow) * ITEM_HEIGHT)))
        context?.strokePath()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
