//
//  TileViewControllerDataSource.swift
//  Swift Reuse Code
//
//  Created by Oliver Klemenz on 26.06.14.
//
//

import Foundation
import UIKit

protocol TileViewControllerDataSource: class {
    func tileName() -> String?
    func tileShowNameInitials() -> Bool
    func tileImage() -> UIImage?
    func tilePositioned() -> Bool
    func setTilePositioned(_ tilePositioned: Bool)
    func tileRow() -> Int
    func setTileRow(_ tileRow: Int)
    func tileColumn() -> Int
    func setTileColumn(_ tileColumn: Int)
}
