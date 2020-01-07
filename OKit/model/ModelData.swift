//
//  ModelData.swift
//  OKit
//
//  Created by Oliver Klemenz on 13.03.19.
//  Copyright © 2020 Oliver Klemenz. All rights reserved.
//

import Foundation
import UIKit

@objc(ModelData)
open class ModelData : ModelHybrid, Codable {
    
    private enum CodingKeys: String, CodingKey {
        case id
        case format
        case label
        case quality
        case scale
        case template
        case size
    }
    
    open var id: String!
    open var format: String = ""
    open var label: String = ""
    open var quality: Float = 0.5
    open var scale: Float = 1.0
    open var template: Bool = false
    open var size: Int = 0
    
    private var _data: Data? {
        didSet {
            size = 0
            if let _data = _data {
                size = _data.count
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
        self.setRetrieved()
    }
}

extension ModelData {
    
    public var data: Data? {
        get {
            return retrieve()
        }
        set {
            _data = newValue
            setPending()
        }
    }
    
    open func retrieve() -> Data? {
        guard !isRetrieved() else {
            return _data
        }
        _data = nil
        if let data = try? read(url: path) {
            _data = data
        }
        setRetrieved()
        return _data
    }
    
    override open func store() {
        if Model.importActive {
            _ = retrieve()
        }
        guard isPending() else {
            return
        }
        super.store()
        let url = path
        if let _data = _data {
            try? write(url: url, data: _data)
        } else if isRetrieved() {
            try? delete(url: url)
        }
    }
    
    override dynamic open func clear() {
        super.clear()
        try? delete(url: path)
    }
    
    override open var path: URL? {
        return URL(string: "_data/\(id!).raw")!
    }
}
