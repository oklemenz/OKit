//
//  ModelData.swift
//  OKit
//
//  Created by Oliver Klemenz on 13.03.19.
//  Copyright © 2020 Oliver Klemenz. All rights reserved.
//

import Foundation
import UIKit

@objc(ModelInlineData)
open class ModelInlineData: ModelEntity, Codable {
    
    private enum CodingKeys: String, CodingKey {
        case id
        case format
        case label
        case quality
        case scale
        case template
        case size
        case data        
    }
    
    public var id: String!
    public var format: String = ""
    public var label: String = ""
    public var quality: Float = 0.5
    public var scale: Float = 1.0
    public var template: Bool = false
    public var size: Int = 0
    
    public  var data: Data? {
        didSet {
            size = 0
            if let data = data {
                size = data.count
            }
        }
    }
    
    public required init() {
        super.init()
    }
    
    public init(data: Data?, format: String = "", label: String = "") {
        super.init()
        self.data = data
        self.format = format
        self.label = label
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        format = try container.decode(String.self, forKey: .format)
        label = try container.decode(String.self, forKey: .label)
        quality = try container.decode(Float.self, forKey: .quality)
        scale = try container.decode(Float.self, forKey: .scale)
        template = try container.decode(Bool.self, forKey: .template)
        size = try container.decode(Int.self, forKey: .size)
        data = try container.decode(Data.self, forKey: .data)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let data = data {
            try container.encode(id, forKey: .id)
            try container.encode(format, forKey: .format)
            try container.encode(label, forKey: .label)
            try container.encode(quality, forKey: .quality)
            try container.encode(scale, forKey: .scale)
            try container.encode(template, forKey: .template)
            try container.encode(size, forKey: .size)
            try container.encode(data, forKey: .data)
        }
    }
}
