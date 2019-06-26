//
//  VideoAnnotationViewController.swift
//  Swift Reuse Code
//
//  Created by Oliver Klemenz on 30.07.14.
//
//

import Foundation
import AVFoundation
import AVKit
import UIKit

class VideoAnnotationViewController: AVPlayerViewController {
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
    }
}
