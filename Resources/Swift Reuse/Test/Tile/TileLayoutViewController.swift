//
//  TileLayoutViewController.swift
//  Swift Reuse Code
//
//  Created by Oliver Klemenz on 01.05.14.
//
//

import UIKit

// TODO: Make this configurable
let ITEM_WIDTH = 200.0
let ITEM_HEIGHT = 240.0
let ITEM_WIDTH_PADDING = 15.0
let ITEM_HEIGHT_PADDING = 15.0
let ITEM_IMAGE_PADDING = 5.0
let BORDER_CELLS = 2

class TileLayoutViewController: UIViewController, UIScrollViewDelegate, TileLayoutViewDelegate {
    var tileDataSources: [TileViewControllerDataSource] = []

    func positionedTiles() -> [Any]? {
        var tiles: [AnyHashable] = []
        for tile in tileLayoutView?.tiles as? [TileViewController] ?? [] {
            if tile.positioned {
                tiles.append(tile)
            }
        }
        return tiles
    }

    func revalidate() {
        tileLayoutView?.revalidate()
        centerScrollViewContents()
    }

    private var tileLayoutView: TileLayoutView?
    private var scrollView: UIScrollView?

    func centerScrollViewContents() {
        if let boundsSize = scrollView?.bounds.size, var contentsFrame = tileLayoutView?.frame {
            if contentsFrame.size.width < boundsSize.width {
                contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
            } else {
                contentsFrame.origin.x = 0.0
            }
            if contentsFrame.size.height < boundsSize.height {
                contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
            } else {
                contentsFrame.origin.y = 0.0
            }
            tileLayoutView?.frame = contentsFrame
        }
    }

    func refresh() {
        let scrollViewFrame: CGRect? = scrollView?.frame
        let scaleWidth: CGFloat = (scrollViewFrame?.size.width ?? 0.0) / (tileLayoutView?.bounds.size.width ?? 0.0)
        let scaleHeight: CGFloat = (scrollViewFrame?.size.height ?? 0.0) / (tileLayoutView?.bounds.size.height ?? 0.0)
        let minScale = min(scaleWidth, scaleHeight)
        scrollView?.minimumZoomScale = minScale
        scrollView?.maximumZoomScale = 5.0
    }

    func didChange() {
        scrollView?.contentSize = tileLayoutView?.frame.size ?? CGSize.zero
        refresh()
        centerScrollViewContents()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView = UIScrollView(frame: view.bounds)
        scrollView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView?.backgroundColor = UIColor.white
        if let scrollView = scrollView {
            view.addSubview(scrollView)
        }
        tileLayoutView = TileLayoutView(frame: CGRect.zero)
        tileLayoutView?.delegate = self
        tileLayoutView?.tileDataSources = tileDataSources
        if let tileLayoutView = tileLayoutView {
            scrollView?.addSubview(tileLayoutView)
        }
        scrollView?.contentSize = tileLayoutView?.bounds.size ?? CGSize.zero
        scrollView?.delegate = self
        scrollView?.delaysContentTouches = false
        scrollView?.zoomScale = scrollView?.minimumZoomScale ?? 0.0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        revalidate()
    }

    override func viewDidAppear(_ animated: Bool) {
        centerScrollViewContents()
    }

    override var shouldAutorotate: Bool {
        return true
    }

// MARK: - UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return tileLayoutView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents()
    }
}
