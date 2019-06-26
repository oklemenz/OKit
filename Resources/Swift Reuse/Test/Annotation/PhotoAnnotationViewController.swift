//
//  PhotoAnnotationViewController.swift
//  Swift Reuse Code
//
//  Created by Oliver Klemenz on 29.07.14.
//
//

import UIKit

protocol PhotoAnnotationViewControllerDelegate: NSObjectProtocol {
    func didFinishEdit(_ image: UIImage?)
}

class PhotoAnnotationViewController: UIViewController, UIScrollViewDelegate, ImageAnnotationViewControllerDelegate {
    weak var delegate: PhotoAnnotationViewControllerDelegate?
    weak var dataSource: ImageAnnotationDataSource?

    init(image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        self.image = image
        navigationItem.rightBarButtonItem = editButtonItem
    }

    private var image: UIImage?
    private var imageView: UIImageView?
    private var scrollView: UIScrollView?

    override func setEditing(_ editing: Bool, animated: Bool) {
        if editing {
            let imageAnnotation = ImageAnnotationViewController()
            imageAnnotation.delegate = self
            imageAnnotation.dataSource = dataSource
            imageAnnotation.image(image)
            navigationController?.pushViewController(imageAnnotation, animated: true)
        }
        super.setEditing(false, animated: animated)
    }

    func didFinishDrawing(_ image: UIImage?, updated: Bool) {
        self.image = image
        setupImage()
        delegate?.didFinishEdit(image)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white

        imageView = UIImageView(image: image)

        scrollView = UIScrollView(frame: view.bounds)
        scrollView?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        scrollView?.delegate = self

        setupImage()

        if let imageView = imageView {
            scrollView?.addSubview(imageView)
        }
        if let scrollView = scrollView {
            view.addSubview(scrollView)
        }
    }

    func setupImage() {
        imageView?.image = image

        /*scrollView?.minimumZoomScale = min((scrollView?.bounds.size.width ?? 0.0) / (imageView?.image?.size.width ?? 0.0) / (imageView?.image?.scale ?? 0.0), (scrollView?.bounds.size.height ?? 0.0) / (imageView?.image?.size.height ?? 0.0) / (imageView?.image?.scale ?? 0.0))*/
        if (scrollView?.minimumZoomScale ?? 0.0) > 1.0 {
            scrollView?.minimumZoomScale = 1.0
        }
        scrollView?.maximumZoomScale = 10.0
        scrollView?.zoomScale = scrollView?.minimumZoomScale ?? 0.0
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
