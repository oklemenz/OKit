//
//  ModelImage.swift
//  ModelBasedApp
//
//  Created by Klemenz, Oliver on 13.03.19.
//  Copyright © 2019 Klemenz, Oliver. All rights reserved.
//

import Foundation
import UIKit

public enum ImageFormat: String, Codable {
    case png = "image/png"
    case jpeg = "image/jpeg"
}

@objc(ModelImage)
open class ModelImage: ModelData {
    
    private var _image: UIImage?
    
    public required init() {
        super.init()
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    public init(image: UIImage?, format: ImageFormat = .jpeg, quality: Float = 0.5, scale: Float = 1.0, template: Bool = false, label: String = "") {
        super.init(data: ModelImage.dataFrom(image: image, format: format, quality: quality), format: format.rawValue, label: label)
        self._image = image
        self.quality = quality
        self.scale = scale
        self.template = template
    }
    
    public convenience init(image: UIImage?, format: ImageFormat = .png, scale: Float = 1.0, template: Bool = false, label: String = "") {
        self.init(image: image, format: format, quality: 0.5, scale: scale, template: template, label: label)
    }
}

extension ModelImage {

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

    override open var path: URL? {
        return URL(string: "_image/\(id!).\(format.split(separator: "/").last!)")!
    }
    
}

extension ModelImage {
    
    public static func dataFrom(image: UIImage?, format: ImageFormat = .jpeg, quality: Float) -> Data? {
        var data: Data?
        if format == .png {
            data = image?.pngData()
        } else {
            data = image?.jpegData(compressionQuality: CGFloat(quality))
        }
        return data
    }
    
    public static func imageFrom(data: Data, scale: Float, template: Bool) -> UIImage? {
        var image: UIImage?
        if scale > 1.0 {
            image = UIImage(data: data, scale: CGFloat(scale))
        } else {
            image = UIImage(data: data)
        }
        if template {
            image = image?.withRenderingMode(.alwaysTemplate)
        }
        return image
    }

}
