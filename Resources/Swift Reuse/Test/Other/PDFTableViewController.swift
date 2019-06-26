//
//  PDFTableViewController.swift
//  Swift Reuse Code
//
//  Created by Oliver Klemenz on 25.05.14.
//
//

import UIKit

class PDFTableViewController: UIViewController, UIWebViewDelegate {
    @IBOutlet var webView: UIWebView!
    private(set) var filePath = ""
    private(set) var fileURL: URL?

    convenience init(settings: [AnyHashable : Any]?) {
        self.init()
        updateSettings(settings)
    }

    func show() {
        //pdfTableCreator?.create()
        var request: URLRequest? = nil
        if let fileURL = fileURL {
            request = URLRequest(url: fileURL)
        }
        webView.scalesPageToFit = true
        webView.delegate = self
        if let request = request {
            webView.loadRequest(request)
        }
    }

    func updateSettings(_ settings: [AnyHashable : Any]?) {
        if let settings = settings {
            self.settings = settings
        }
        filePath = settings?["Creator"] as? String ?? ""
        fileURL = URL(fileURLWithPath: filePath)
    }

    private var settings: [AnyHashable : Any] = [:]
    private var landscape = false

    override func viewDidLoad() {
        webView = UIWebView(frame: view.bounds)
        webView.backgroundColor = UIColor.white
        webView.delegate = self
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(webView)

        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(PDFTableViewController.changeOrientation(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        perform(#selector(PDFTableViewController.scrollToCenter), with: nil, afterDelay: 0.1)
    }

    @objc func scrollToCenter() {
        var scrollHeight: CGFloat = webView.scrollView.contentSize.height - webView.bounds.size.height
        if 0.0 > scrollHeight {
            scrollHeight = 0.0
        }
        webView.scrollView.setContentOffset(CGPoint(x: 0.0, y: scrollHeight / 2.0), animated: true)
    }

    @objc func changeOrientation(_ notification: Notification?) {
        if settings["Orientation"] as? Bool == true {
            let currentDeviceOrientation: UIDeviceOrientation = UIDevice.current.orientation
            if currentDeviceOrientation == .landscapeLeft || currentDeviceOrientation == .portraitUpsideDown {
                webView.transform = CGAffineTransform(rotationAngle: .pi)
            } else {
                webView.transform = .identity
            }
            if (UIDevice.current.orientation.isLandscape && !landscape) || (UIDevice.current.orientation.isPortrait && landscape) {
                show()
            }
            landscape = UIDevice.current.orientation.isLandscape
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
}
