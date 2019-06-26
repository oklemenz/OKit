//
//  ModelImage.swift
//  OKit
//
//  Created by Klemenz, Oliver on 03.03.19.
//  Copyright © 2019 Klemenz, Oliver. All rights reserved.
//

import Foundation
import UIKit

@objc(ModelInlineImage)
open class ModelInlineImage: ModelInlineData {
    
    public required init() {
        super.init()
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    public init(image: UIImage?, format: ImageFormat = .jpeg, quality: Float = 0.5, label: String = "") {
        super.init(data: ModelImage.dataFrom(image: image, format: format, quality: quality), format: format.rawValue, label: label)
        self._image = image
        self.quality = quality
    }
    
    public convenience init(image: UIImage?, format: ImageFormat = .png, label: String = "") {
        self.init(image: image, format: format, quality: 0.5, label: label)
    }

    private var _image: UIImage?
    public var image: UIImage? {
        get {
            if _image == nil, let data = data {
                _image = ModelImage.imageFrom(data: data, scale: scale, template: template)
            }
            return _image
        }
        set {
            if _image != newValue {
                _image = newValue
                data = ModelImage.dataFrom(image: _image, quality: quality)
            }
        }
    }
}
