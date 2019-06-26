//  Converted to Swift 5 by Swiftify v5.0.29819 - https://objectivec2swift.com/
//
//  PDFTableCreator.swift
//  TeacherPlanner
//
//  Created by Klemenz, Oliver on 27.05.14.
//  Copyright (c) 2014 Oliver Klemenz. All rights reserved.
//

import CoreText
import Foundation
import UIKit

let kPDFTableCreatorFilePath = "kPDFTableCreatorFilePath"
let kPDFTableCreatorHeader = "kPDFTableCreatorHeader"
let kPDFTableCreatorHeaderTextColor = "kPDFTableCreatorHeaderTextColor"
let kPDFTableCreatorHorizontalAlignmentHeader = "kPDFTableCreatorHorizontalAlignmentHeader"
let kPDFTableCreatorFooter = "kPDFTableCreatorFooter"
let kPDFTableCreatorFooterTextColor = "kPDFTableCreatorFooterTextColor"
let kPDFTableCreatorHorizontalAlignmentFooter = "kPDFTableCreatorHorizontalAlignmentFooter"
let kPDFTableCreatorFooter2 = "kPDFTableCreatorFooter2"
let kPDFTableCreatorFooter2TextColor = "kPDFTableCreatorFooter2TextColor"
let kPDFTableCreatorHorizontalAlignmentFooter2 = "kPDFTableCreatorHorizontalAlignmentFooter2"
let kPDFTableCreatorSupportCellSpan = "kPDFTableCreatorSupportCellSpan"
let kPDFTableCreatorColumns = "kPDFTableCreatorColumns"
let kPDFTableCreatorRows = "kPDFTableCreatorRows"
let kPDFTableCreatorTopHeaders = "kPDFTableCreatorTopHeaders"
let kPDFTableCreatorLeftHeaders = "kPDFTableCreatorLeftHeaders"
let kPDFTableCreatorContent = "kPDFTableCreatorContent"
let kPDFTableCreatorDefaultOrientation = "kPDFTableCreatorDefaultOrientation"
let kPDFTableCreatorOrientationSupport = "kPDFTableCreatorOrientationSupport"
let kPDFTableCreatorOptimalOrientation = "kPDFTableCreatorOptimalOrientation"
let kPDFTableCreatorPageBorderX = "kPDFTableCreatorPageBorderX"
let kPDFTableCreatorPageBorderY = "kPDFTableCreatorPageBorderY"
let kPDFTableCreatorImageBorderX = "kPDFTableCreatorImageBorderX"
let kPDFTableCreatorImageBorderY = "kPDFTableCreatorImageBorderY"
let kPDFTableCreatorAttributedStringScale = "kPDFTableCreatorAttributedStringScale"
let kPDFTableCreatorAttributedStringFill = "kPDFTableCreatorAttributedStringFill"
let kPDFTableCreatorAttributedStringFillRect = "kPDFTableCreatorAttributedStringFillRect"
let kPDFTableCreatorAttributedStringFillCircle = "kPDFTableCreatorAttributedStringFillCircle"
let kPDFTableCreatorAttributedStringAspectMode = "kPDFTableCreatorAttributedStringAspectMode"
let kPDFTableCreatorAttributedStringAspectModeSquare = "kPDFTableCreatorAttributedStringAspectModeSquare"
let kPDFTableCreatorAttributedStringText = "kPDFTableCreatorAttributedStringText"
let kPDFTableCreatorAttributedStringIcon = "kPDFTableCreatorAttributedStringIcon"
let kPDFTableCreatorAttributedStringRibbon = "kPDFTableCreatorAttributedStringRibbon"
let kPDFTableCreatorAttributedStringRibbonRelativeHeight = "kPDFTableCreatorAttributedStringRibbonRelativeHeight"
let kPDFTableCreatorAttributedStringRibbonRelativeToCell = "kPDFTableCreatorAttributedStringRibbonRelativeToCell"
let kPDFTableCreatorAttributedStringRibbonAbsoluteHeight = "kPDFTableCreatorAttributedStringRibbonAbsoluteHeight"
let kPDFTableCreatorAttributedStringSettings = "kPDFTableCreatorAttributedStringSettings"
let kPDFTableCreatorTableBorderStyle = "kPDFTableCreatorTableBorderStyle"
let kPDFTableCreatorTableBorderStyleSolid = "kPDFTableCreatorTableBorderStyleSolid"
let kPDFTableCreatorTableBorderStyleDashed = "kPDFTableCreatorTableBorderStyleDashed"
let kPDFTableCreatorTableBorderWidth = "kPDFTableCreatorTableBorderWidth"
let kPDFTableCreatorTableBorderColor = "kPDFTableCreatorTableBorderColor"
let kPDFTableCreatorTableFillColor = "kPDFTableCreatorTableFillColor"
let kPDFTableCreatorTableTopHeaderFillColor = "kPDFTableCreatorTableTopHeaderFillColor"
let kPDFTableCreatorTableLeftHeaderFillColor = "kPDFTableCreatorTableLeftHeaderFillColor"
let kPDFTableCreatorTableTextColor = "kPDFTableCreatorTableTextColor"
let kPDFTableCreatorTableTextFontMin = "kPDFTableCreatorTableTextFontMin"
let kPDFTableCreatorCellRatio = "kPDFTableCreatorCellRatio"
let kPDFTableCreatorCellPaddingX = "kPDFTableCreatorCellPaddingX"
let kPDFTableCreatorCellPaddingY = "kPDFTableCreatorCellPaddingY"
let kPDFTableCreatorCellSpanX = "kPDFTableCreatorCellSpanX"
let kPDFTableCreatorCellSpanY = "kPDFTableCreatorCellSpanY"
let kPDFTableCreatorCellConflict = "kPDFTableCreatorCellConflict"
let kPDFTableCreatorHorizontalAlignmentText = "kPDFTableCreatorHorizontalAlignmentText"
let kPDFTableCreatorHorizontalAlignmentImage = "kPDFTableCreatorHorizontalAlignmentImage"
let kPDFTableCreatorHorizontalAlignmentLeft = "kPDFTableCreatorHorizontalAlignmentLeft"
let kPDFTableCreatorHorizontalAlignmentCenter = "kPDFTableCreatorHorizontalAlignmentCenter"
let kPDFTableCreatorHorizontalAlignmentRight = "kPDFTableCreatorHorizontalAlignmentRight"
let kPDFTableCreatorVerticalAlignmentText = "kPDFTableCreatorVerticalAlignmentText"
let kPDFTableCreatorVerticalAlignmentImage = "kPDFTableCreatorVerticalAlignmentImage"
let kPDFTableCreatorVerticalAlignmentTop = "kPDFTableCreatorVerticalAlignmentTop"
let kPDFTableCreatorVerticalAlignmentMiddle = "kPDFTableCreatorVerticalAlignmentMiddle"
let kPDFTableCreatorVerticalAlignmentBottom = "kPDFTableCreatorVerticalAlignmentBottom"

class PDFTableCreator: NSObject {

    var paragraphRef = CTParagraphStyleCreate(settings, 2)
    var attributes = attributedText.attributes(at: 0, effectiveRange: nil)
    var framesetter = CTFramesetterCreateWithAttributedString(attributedText as? CFAttributedString?)
    // Vertical Alignment
    var biasY: CGFloat = 0
    var factor: CGFloat = landscape ? -1 : 1
    var suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, attributedText.length), attributes as? CFDictionary?, CGSize(width: rect?.size.width ?? 0.0, height: CGFLOAT_MAX), nil)
    var suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, attributedText.length), attributes as? CFDictionary?, CGSize(width: rect?.size.width ?? 0.0, height: CGFLOAT_MAX), nil)
    var biasY: factor?
    var rect: factor?
    var framePath = CGMutablePath()
    var currentRange: CFRange = CFRangeMake(0, 0)
    var frameRef = CTFramesetterCreateFrame(framesetter, currentRange, framePath, nil)
    var currentContext = UIGraphicsGetCurrentContext()
    currentContext?.saveGState()
    currentContext?.restoreGState()
    var currentContext = UIGraphicsGetCurrentContext()
    currentContext?.saveGState()
    currentContext?.restoreGState()
    var currentContext = UIGraphicsGetCurrentContext()
    currentContext?.saveGState()
    currentContext?.restoreGState()
    var offset = CGPoint.zero
    var currentContext = UIGraphicsGetCurrentContext()
    currentContext?.saveGState()
    currentContext?.restoreGState()
    var currentContext = UIGraphicsGetCurrentContext()
    currentContext?.saveGState()
    currentContext?.restoreGState()
    var contentRect = CGSize(width: rect?.size.width ?? 0 - 2 * imageBorderX, height: rect?.size.height ?? 0 - 2 * imageBorderY)
    var ratio = CGFloat(fmin(Float(contentRect.width / size?.width ?? 0.0), Float(contentRect.height / size?.height ?? 0.0)))
    var ratio: width?
    var size: width?
    // Horizontal Alignment
    var offsetX: CGFloat = 0
    var offsetY: CGFloat = 0
    var cellWidth: CGFloat = 0.0
    var cellHeight: CGFloat = 0.0
    var ratio: cellWidth?
    var cellWidth: CGFloat = 0.0
    var cellHeight: CGFloat = 0.0
    var tableOffsetX: CGFloat = 0
    var tableOffsetY: CGFloat = 0
    var cellWidth: CGFloat = 0.0
    var cellHeight: CGFloat = 0.0
    var: rows?
    var: rows?
    var ratio: cellWidth?
    var: columns?
    var: columns?
    var factor: CGFloat = landscape ? -1 : 1
    var factor: CGFloat = landscape ? -1 : 1
    var tableOffset: CGFloat = landscape ? tableOffset.x : tableOffset.y
    var tableOffsetY: CGFloat = landscape ? tableOffset.y + tableOffset.x : 0
    var: factor?
    var factor: CGFloat = landscape ? -1 : 1
    var tableOffset: CGFloat = landscape ? tableOffset.x : tableOffset.y
    var tableOffsetY: CGFloat = landscape ? tableOffset.y + tableOffset.x : 0
    var: factor?
    var dashed = false
    var dashed = false
    var i: Int = 1
    var start = CGPoint(x: pageBorderY + tableOffset.x, y: CGFloat(pageBorderX + tableOffset.y + i * cellSize().width))
    var end = CGPoint(x: CGFloat(pageBorderY + tableOffset.x + rows * cellSize().height), y: CGFloat(pageBorderX + tableOffset.y + i * cellSize().width))
    var j: Int = 1
    var start = CGPoint(x: CGFloat(pageBorderY + tableOffset.x + j * cellSize().height), y: pageBorderX + tableOffset.y)
    var end = CGPoint(x: CGFloat(pageBorderY + tableOffset.x + j * cellSize().height), y: CGFloat(pageBorderX + tableOffset.y + columns * cellSize().width))
    var i: Int = 1
    var start = CGPoint(x: CGFloat(pageBorderX + tableOffset.x + i * cellSize().width), y: pageBorderY + tableOffset.y)
    var end = CGPoint(x: CGFloat(pageBorderX + tableOffset.x + i * cellSize().width), y: CGFloat(pageBorderY + tableOffset.y + rows * cellSize().height))
    var j: Int = 1
    var start = CGPoint(x: pageBorderX + tableOffset.x, y: CGFloat(pageBorderY + tableOffset.y + j * cellSize().height))
    var end = CGPoint(x: CGFloat(pageBorderX + tableOffset.x + columns * cellSize().width), y: CGFloat(pageBorderY + tableOffset.y + j * cellSize().height))
    var dashed = false
    var column: Int = 0
    var NSInteger: Int = 0
    var cellSpan = false
    var NSInteger = false
    var start = CGPoint(x: pageBorderY + tableOffset.x + last * cellSize().height, y: CGFloat(pageBorderX + tableOffset.y + (columns - column) * cellSize().width))
    var end = CGPoint(x: CGFloat(pageBorderY + tableOffset.x + row * cellSize().height), y: CGFloat(pageBorderX + tableOffset.y + (columns - column) * cellSize().width))
    var column: Int = 0
    var NSInteger: Int = 0
    var cellSpan = false
    var NSInteger = false
    var start = CGPoint(x: CGFloat(pageBorderY + tableOffset.x + row * cellSize().height), y: CGFloat(pageBorderX + tableOffset.y + (columns - last) * cellSize().width))
    var end = CGPoint(x: CGFloat(pageBorderY + tableOffset.x + row * cellSize().height), y: CGFloat(pageBorderX + tableOffset.y + (columns - column) * cellSize().width))
    var column: Int = 0
    var NSInteger: Int = 0
    var cellSpan = false
    var NSInteger = false
    var start = CGPoint(x: CGFloat(pageBorderX + tableOffset.x + column * cellSize().width), y: pageBorderY + tableOffset.y + last * cellSize().height)
    var end = CGPoint(x: CGFloat(pageBorderX + tableOffset.x + column * cellSize().width), y: CGFloat(pageBorderY + tableOffset.y + row * cellSize().height))
    var column: Int = 0
    var NSInteger: Int = 0
    var cellSpan = false
    var NSInteger = false
    var start = CGPoint(x: pageBorderX + tableOffset.x + last * cellSize().width, y: CGFloat(pageBorderY + tableOffset.y + row * cellSize().height))
    var end = CGPoint(x: CGFloat(pageBorderX + tableOffset.x + column * cellSize().width), y: CGFloat(pageBorderY + tableOffset.y + row * cellSize().height))
    var: ((_ column: Int, _ row: Int, _ cellSpan: Bool, _ lastCell: Int) -> Void)?
    var columnBias: Int = 0
    var rowBias: Int = 0
    var j: Int = 0
    var lastCell: Int = 0
    var i: Int = 0
    var row: Int = rowBased ? j : i
    var column: Int = rowBased ? i : j
    var cellSpanCode: Int = cellSpan[row][column].intValue
    var cellSpan = false
    var i: Int = 0
    var cellRect: CGRect = cellRect(i, y: 0)
    var j: Int = 0
    var cellRect: CGRect = cellRect(0, y: j + 1)
    var contentText = ""
    
    init(settings: [AnyHashable : Any]?) {
        super.init()
        pdfFilePath = settings?[kPDFTableCreatorFilePath] as? String ?? ""

        headerText = settings?[kPDFTableCreatorHeader] as? String ?? ""
        headerTextColor = UIColor.black
        //if settings?[kPDFTableCreatorHeaderTextColor]
        headerTextColor = settings?[kPDFTableCreatorHeaderTextColor] as? UIColor
        horizontalAlignHeader = kPDFTableCreatorHorizontalAlignmentCenter
        //if settings?[kPDFTableCreatorHorizontalAlignmentHeader]
        horizontalAlignHeader = settings?[kPDFTableCreatorHorizontalAlignmentHeader] as? String ?? ""
        footerText = settings?[kPDFTableCreatorFooter] as? String ?? ""
        footerTextColor = UIColor.black
        //if settings?[kPDFTableCreatorFooterTextColor]
        footerTextColor = settings?[kPDFTableCreatorFooterTextColor] as? UIColor
        horizontalAlignFooter = kPDFTableCreatorHorizontalAlignmentCenter
        //if settings?[kPDFTableCreatorHorizontalAlignmentFooter]
        horizontalAlignFooter = settings?[kPDFTableCreatorHorizontalAlignmentFooter] as? String ?? ""
        footer2Text = settings?[kPDFTableCreatorFooter2] as? String ?? ""
        footer2TextColor = UIColor.black
        //if settings?[kPDFTableCreatorFooter2TextColor]
        footer2TextColor = settings?[kPDFTableCreatorFooter2TextColor] as? UIColor
        horizontalAlignFooter2 = kPDFTableCreatorHorizontalAlignmentCenter
        //if settings?[kPDFTableCreatorHorizontalAlignmentFooter]
        horizontalAlignFooter2 = settings?[kPDFTableCreatorHorizontalAlignmentFooter2] as? String ?? ""
        supportCellSpan = false
        if (settings?[kPDFTableCreatorSupportCellSpan] as? NSNumber)?.boolValue {
            supportCellSpan = true
        }

        pageBorderX = CGFloat(kPDFPageBorder)
        //if settings?[kPDFTableCreatorPageBorderX]
        pageBorderX = CGFloat((settings?[kPDFTableCreatorPageBorderX] as? NSNumber)?.floatValue)
        pageBorderY = CGFloat(kPDFPageBorder)
        //if settings?[kPDFTableCreatorPageBorderY]
        pageBorderY = CGFloat((settings?[kPDFTableCreatorPageBorderY] as? NSNumber)?.floatValue)
        imageBorderX = CGFloat(kPDFImageBorder)
        //if settings?[kPDFTableCreatorImageBorderX]
        imageBorderX = CGFloat((settings?[kPDFTableCreatorImageBorderX] as? NSNumber)?.floatValue)
        imageBorderY = CGFloat(kPDFImageBorder)
        //if settings?[kPDFTableCreatorImageBorderY]
        imageBorderY = CGFloat((settings?[kPDFTableCreatorImageBorderY] as? NSNumber)?.floatValue)
        cellPaddingX = CGFloat(kPDFCellPadding)
        //if settings?[kPDFTableCreatorCellPaddingX]
        cellPaddingX = CGFloat((settings?[kPDFTableCreatorCellPaddingX] as? NSNumber)?.floatValue)
        cellPaddingY = CGFloat(kPDFCellPadding)
        //if settings?[kPDFTableCreatorCellPaddingY]
        cellPaddingY = CGFloat((settings?[kPDFTableCreatorCellPaddingY] as? NSNumber)?.floatValue)
        fontMin = CGFloat(kPDFFontMin)
        //if settings?[kPDFTableCreatorTableTextFontMin]
        fontMin = CGFloat((settings?[kPDFTableCreatorTableTextFontMin] as? NSNumber)?.floatValue)
        tableTextColor = kPDFTableTextColor
        //if settings?[kPDFTableCreatorTableTextColor]
        tableTextColor = settings?[kPDFTableCreatorTableTextColor] as? UIColor
        tableBorderStyle = kPDFTableCreatorTableBorderStyleSolid
        //if settings?[kPDFTableCreatorTableBorderStyle]
        tableBorderStyle = settings?[kPDFTableCreatorTableBorderStyle] as? String ?? ""
        tableBorderColor = kPDFTableBorderColor
        //if settings?[kPDFTableCreatorTableBorderColor]
        tableBorderColor = settings?[kPDFTableCreatorTableBorderColor] as? UIColor
        tableFillColor = kPDFTableFillColor
        //if settings?[kPDFTableCreatorTableFillColor]
        tableFillColor = settings?[kPDFTableCreatorTableFillColor] as? UIColor
        tableTopHeaderFillColor = kPDFTableHeaderFillColor
        //if settings?[kPDFTableCreatorTableTopHeaderFillColor]
        tableTopHeaderFillColor = settings?[kPDFTableCreatorTableTopHeaderFillColor] as? UIColor
        tableLeftHeaderFillColor = kPDFTableHeaderFillColor
        //if settings?[kPDFTableCreatorTableLeftHeaderFillColor]
        tableLeftHeaderFillColor = settings?[kPDFTableCreatorTableLeftHeaderFillColor] as? UIColor
        tableBorderWidth = CGFloat(kPDFTableBorderWidth)
        //if settings?[kPDFTableCreatorTableBorderWidth]
        tableBorderWidth = CGFloat((settings?[kPDFTableCreatorTableBorderWidth] as? NSNumber)?.floatValue)
        horizontalAlignText = kPDFTableCreatorHorizontalAlignmentCenter
        //if settings?[kPDFTableCreatorHorizontalAlignmentText]
        horizontalAlignText = settings?[kPDFTableCreatorHorizontalAlignmentText] as? String ?? ""
        verticalAlignText = kPDFTableCreatorVerticalAlignmentMiddle
        //if settings?[kPDFTableCreatorVerticalAlignmentText]
        verticalAlignText = settings?[kPDFTableCreatorVerticalAlignmentText] as? String ?? ""
        horizontalAlignImage = kPDFTableCreatorHorizontalAlignmentCenter
        //if settings?[kPDFTableCreatorHorizontalAlignmentImage]
        horizontalAlignImage = settings?[kPDFTableCreatorHorizontalAlignmentImage] as? String ?? ""
        verticalAlignImage = kPDFTableCreatorVerticalAlignmentMiddle
        //if settings?[kPDFTableCreatorVerticalAlignmentImage]
        verticalAlignImage = settings?[kPDFTableCreatorVerticalAlignmentImage] as? String ?? ""

        if let headers = settings?[kPDFTableCreatorTopHeaders] as? [Any] {
            topHeaders = headers
        }
        if let headers = settings?[kPDFTableCreatorLeftHeaders] as? [Any] {
            leftHeaders = headers
        }
        if let content = settings?[kPDFTableCreatorContent] as? [Any] {
            content = content
        }

        withTopHeaders = topHeaders != nil
        withLeftHeaders = leftHeaders != nil

        columns = (settings?[kPDFTableCreatorColumns] as? NSNumber)?.intValue
        rows = (settings?[kPDFTableCreatorRows] as? NSNumber)?.intValue

        landscape = false
        if UIDeviceOrientationIsLandscape((settings?[kPDFTableCreatorDefaultOrientation] as? NSNumber)?.intValue) {
            landscape = true
        }
        optimalOrientation = false
        if (settings?[kPDFTableCreatorOptimalOrientation] as? NSNumber)?.boolValue {
            optimalOrientation = true
        }
        orientationSupport = false
        if (settings?[kPDFTableCreatorOrientationSupport] as? NSNumber)?.boolValue {
            orientationSupport = true
        }

        cellRatio = 0.0
        //if settings?[kPDFTableCreatorCellRatio]
        cellRatio = CGFloat((settings?[kPDFTableCreatorCellRatio] as? NSNumber)?.floatValue)
    }

    func create() {
        if orientationSupport {
            landscape = UIDeviceOrientationIsLandscape(UIDevice.current.orientation)
        }

        // Determine layouting
        cellSize = cellSize(columns, rows: rows, ratio: cellRatio)
        tableSize = tableSize(columns, rows: rows, ratio: cellRatio)
        tableOffset = tableOffset(columns, rows: rows, ratio: cellRatio)

        if optimalOrientation {
            if tableSize.width > tableSize.height {
                landscape = true
                cellSize = cellSize(columns, rows: rows, ratio: cellRatio)
                tableSize = tableSize(columns, rows: rows, ratio: cellRatio)
                tableOffset = tableOffset(columns, rows: rows, ratio: cellRatio)
            }
        }

        // Start PDF Rendering
        startPDF(pdfFilePath)
        newPDFPage()

        let headerFont = UIFont.boldSystemFont(ofSize: CGFloat(kPDFFontHeader))
        let footerFont = UIFont.italicSystemFont(ofSize: CGFloat(kPDFFontFooter))

        drawTableHeader(headerText, font: headerFont, color: headerTextColor, horizontalAlign: horizontalAlignHeader)

        if columns > 0 && rows > 0 {

            determineCellSpan(columns, rows: rows, content: content)

            //[self logCellSpan];

            drawTableBackground(columns, rows: rows, content: content)

            if supportCellSpan {
                drawTableSpan(columns, rows: rows, width: tableBorderWidth, color: tableBorderColor, fill: tableFillColor, topHeaderFill: tableTopHeaderFillColor, leftHeaderFill: tableLeftHeaderFillColor, style: tableBorderStyle, content: content)
            } else {
                drawTable(columns, rows: rows, width: tableBorderWidth, color: tableBorderColor, fill: tableFillColor, topHeaderFill: tableTopHeaderFillColor, leftHeaderFill: tableLeftHeaderFillColor, style: tableBorderStyle)
            }

            var actualSize = CGFloat(kPDFFontText) //[UIFont systemFontSize];
            var actualMinSize = CGFloat(kPDFFontText) //[UIFont systemFontSize];
            var font = UIFont.systemFont(ofSize: UIFont.systemFontSize)

            if withTopHeaders {
                for header in topHeaders as? [String] ?? [] {
                //#pragma clang diagnostic push
                //#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    header.size(with: UIFont.systemFont(ofSize: actualSize), minFontSize: fontMin, actualFontSize: &actualSize, forWidth: cellSize.width - 20, lineBreakMode: NSLineBreakMode.byWordWrapping)
                //#pragma clang diagnostic pop
                    if actualSize < actualMinSize {
                        actualMinSize = actualSize
                    }
                }
                var font = UIFont.boldSystemFont(ofSize: actualMinSize)
                drawTableTopHeaders(columns, rows: rows, headers: topHeaders, font: font, color: tableTextColor)
            }

            if withLeftHeaders {
                for header in leftHeaders as? [String] ?? [] {
                //#pragma clang diagnostic push
                //#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    header.size(with: UIFont.systemFont(ofSize: actualSize), minFontSize: fontMin, actualFontSize: &actualSize, forWidth: cellSize.width - 20, lineBreakMode: NSLineBreakMode.byWordWrapping)
                //#pragma clang diagnostic pop
                    if actualSize < actualMinSize {
                        actualMinSize = actualSize
                    }
                }
                font = UIFont.boldSystemFont(ofSize: actualMinSize)
                drawTableLeftHeaders(columns, rows: rows, headers: leftHeaders, font: font, color: tableTextColor)
            }

            font = UIFont.systemFont(ofSize: actualMinSize)

            let imageRect: CGRect = drawTableContentImage(columns, rows: rows, content: content, horizontalAlign: horizontalAlignImage, verticalAlign: verticalAlignImage)

            var maxTextHeight: CGFloat = 0
            if !imageRect.isEmpty() {
                maxTextHeight = max(cellSize.height - imageRect.size.height - 2 * imageBorderY - 2 * cellPaddingY, 0)
            }

            drawTableContentText(columns, rows: rows, content: content, font: font, color: tableTextColor, horizontalAlign: horizontalAlignText, verticalAlign: verticalAlignText, maxSize: CGSize(width: 0, height: maxTextHeight))

            drawTableForeground(columns, rows: rows, content: content)
        }

        drawTableFooter(footerText, font: footerFont, color: footerTextColor, horizontalAlign: horizontalAlignFooter)
        drawTableFooter(footer2Text, font: footerFont, color: footer2TextColor, horizontalAlign: horizontalAlignFooter2)

        finishPDF()
    }

    class func attributedStringIcon(_ icon: UIImage?, scale: CGFloat, settings: [AnyHashable : Any]?) -> NSAttributedString? {
    }

    class func attributedStringText(_ text: String?, fontSize: CGFloat, scale: CGFloat, color: UIColor?, settings: [AnyHashable : Any]?) -> NSAttributedString? {
    }

    class func attributedStringFill(_ fillMode: String?, aspectMode: String?, scale: CGFloat, fill fillColor: UIColor?, settings: [AnyHashable : Any]?) -> NSAttributedString? {
    }

    class func attributedStringRibbon(_ fillColor: UIColor?, relativeHeight: CGFloat, relativeToCell: Bool, settings: [AnyHashable : Any]?) -> NSAttributedString? {
    }

    class func attributedStringRibbon(_ fillColor: UIColor?, absoluteHeight: CGFloat, settings: [AnyHashable : Any]?) -> NSAttributedString? {
    }

    class func attributedStringSpanX(_ spanX: Int, spanY: Int, settings: [AnyHashable : Any]?) -> NSAttributedString? {
    }

    class func attributedStringConflict(_ settings: [AnyHashable : Any]?) -> NSAttributedString? {
    }

    private var pdfFilePath = ""
    private var landscape = false
    private var orientationSupport = false
    private var optimalOrientation = false
    private var supportCellSpan = false
    private var columns: Int = 0
    private var rows: Int = 0
    private var headerText = ""
    private var horizontalAlignHeader = ""
    private var headerTextColor: UIColor?
    private var footerText = ""
    private var horizontalAlignFooter = ""
    private var footerTextColor: UIColor?
    private var footer2Text = ""
    private var horizontalAlignFooter2 = ""
    private var footer2TextColor: UIColor?
    private var cellRatio: CGFloat = 0.0
    private var pageBorderX: CGFloat = 0.0
    private var pageBorderY: CGFloat = 0.0
    private var imageBorderX: CGFloat = 0.0
    private var imageBorderY: CGFloat = 0.0
    private var cellPaddingX: CGFloat = 0.0
    private var cellPaddingY: CGFloat = 0.0
    private var tableBorderWidth: CGFloat = 0.0
    private var fontMin: CGFloat = 0.0
    private var tableOffset = CGPoint.zero
    private var cellSize = CGSize.zero
    private var tableSize = CGSize.zero
    private var withTopHeaders = false
    private var withLeftHeaders = false
    private var tableTextColor: UIColor?
    private var tableBorderColor: UIColor?
    private var tableFillColor: UIColor?
    private var tableTopHeaderFillColor: UIColor?
    private var tableLeftHeaderFillColor: UIColor?
    private var tableBorderStyle = ""
    private var horizontalAlignText = ""
    private var verticalAlignText = ""
    private var horizontalAlignImage = ""
    private var verticalAlignImage = ""
    private var topHeaders: [Any] = []
    private var leftHeaders: [Any] = []
    private var content: [Any] = []
    private var cellSpan: [AnyHashable] = []

    func startPDF(_ filename: String?) {
        UIGraphicsBeginPDFContextToFile(filename, CGRect.zero, nil)
    }

    func newPDFPage() {
        let pageRect = CGRect(x: 0, y: 0, width: CGFloat(kPDFPageWidth), height: CGFloat(kPDFPageHeight))
        UIGraphicsBeginPDFPageWithInfo(pageRect, nil)
    }

    func finishPDF() {
        UIGraphicsEndPDFContext()
    }

    func draw(_ rect: CGRect, width: CGFloat, dashed: Bool, color: UIColor?) {
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(width)
        context?.setLineDash(phase: 0, lengths: nil)
        if dashed {
            let dash = [5.0, 2.0]
            context?.setLineDash(phase: 0.0, lengths: dash)
        }
        if color != nil {
            if let CGColor = color?.cgColor {
                context?.setStrokeColor(CGColor)
            }
        }
        context?.stroke(rect)
    }

    func drawFilledRect(_ rect: CGRect, fill fillColor: UIColor?) {
        let currentContext = UIGraphicsGetCurrentContext()
        if fillColor != nil {
            currentContext?.setFillColor(fillColor?.cgColor)
        }
        currentContext?.fill(rect)
    }

    func drawFilledCircle(_ rect: CGRect, fill fillColor: UIColor?) {
        let currentContext = UIGraphicsGetCurrentContext()
        if fillColor != nil {
            currentContext?.setFillColor(fillColor?.cgColor)
        }
        currentContext?.fillEllipse(in: rect)
    }

    func drawLine(_ from: CGPoint, to: CGPoint, width: CGFloat, dashed: Bool, color: UIColor?) {
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(width)
        context?.setLineDash(phase: 0, lengths: nil)
        if dashed {
            let dash = [5.0, 2.0]
            context?.setLineDash(phase: 0.0, lengths: dash)
        }
        if color != nil {
            if let CGColor = color?.cgColor {
                context?.setStrokeColor(CGColor)
            }
        }
        context?.move(to: CGPoint(x: from.x, y: from.y))
        context?.addLine(to: CGPoint(x: to.x, y: to.y))
        context?.strokePath()
    }

    func setDrawOrientation(_ currentContext: CGContext?, rect: CGRect, offset: CGPoint) {
        setDrawOrientation(currentContext, rect: rect, offset: offset, inCell: true)
    }

    func setDrawOrientation(_ currentContext: CGContext?, rect: CGRect, offset: CGPoint, inCell: Bool) {
        if landscape {
            currentContext?.textMatrix = .identity
            currentContext?.rotate(by: M_PI_2)
            currentContext?.translateBy(x: CGFloat(kPDFPageHeight) - rect.size.width - 2 * (pageBorderX + (inCell ? cellPaddingX : 0) + offset.x) - tableOffset.x - tableOffset.y, y: 0 - rect.size.height - 2 * (pageBorderY + (inCell ? cellPaddingY : 0) + offset.y) - tableOffset.x - tableOffset.y)
            currentContext?.translateBy(x: rect.size.width + 2 * rect.origin.x, y: 0)
            currentContext?.scaleBy(x: -1.0, y: 1.0)
        } else {
            currentContext?.textMatrix = .identity
            currentContext?.translateBy(x: 0, y: rect.size.height + 2 * rect.origin.y)
            currentContext?.scaleBy(x: 1.0, y: -1.0)
        }
    }

    func drawOrientedText(_ text: String?, in rect: CGRect, font: UIFont?, color: UIColor?, horizontalAlign: String?, verticalAlign: String?, offset: CGPoint) {
        drawOrientedText(text, in: rect, font: font, color: color, horizontalAlign: horizontalAlign, verticalAlign: verticalAlign, offset: offset, inCell: true)
    }

    func drawOrientedText(_ text: String?, in rect: CGRect, font: UIFont?, color: UIColor?, horizontalAlign: String?, verticalAlign: String?, offset: CGPoint, inCell: Bool) {
        var attributes: [AnyHashable : Any] = [:]
        var fontRef: CTFont? = nil
        if font != nil {
            fontRef = CTFontCreateWithName(font?.fontName as CFString?, font?.pointSize, nil)
            if let kCTFontAttributeName = kCTFontAttributeName, let fontRef = fontRef {
                attributes[kCTFontAttributeName] = fontRef
            }
        }
        if color != nil {
            if let kCTForegroundColorAttributeName = kCTForegroundColorAttributeName, let CGColor = color?.cgColor {
                attributes[kCTForegroundColorAttributeName] = CGColor
            }
        }
        let attributedText = NSAttributedString(string: text ?? "", attributes: attributes as? [NSAttributedString.Key : Any])
        drawOrientedAttributedText(attributedText, in: rect, horizontalAlign: horizontalAlign, verticalAlign: verticalAlign, offset: offset, inCell: inCell)
    }

    func drawOrientedAttributedText(_ attributedText: NSAttributedString?, in rect: CGRect, horizontalAlign: String?, verticalAlign: String?, offset: CGPoint) {
        drawOrientedAttributedText(attributedText, in: rect, horizontalAlign: horizontalAlign, verticalAlign: verticalAlign, offset: offset, inCell: true)
    }

    func drawOrientedAttributedText(_ attributedText: NSAttributedString?, in rect: CGRect, horizontalAlign: String?, verticalAlign: String?, offset: CGPoint, inCell: Bool) {
        var attributedText = attributedText
        // Horizontal Alignment
        var alignment: CTTextAlignment = .kCTLeftTextAlignment
        if (horizontalAlign == kPDFTableCreatorHorizontalAlignmentCenter) {
            alignment = .kCTCenterTextAlignment
        } else if (horizontalAlign == kPDFTableCreatorHorizontalAlignmentRight) {
            alignment = .kCTRightTextAlignment
        }
        let alignmentSetting: CTParagraphStyleSetting
        alignmentSetting.spec = .alignment
        alignmentSetting.valueSize = MemoryLayout<CTTextAlignment>.size
        alignmentSetting.value = alignment

        //attributedText = attributedText    // Skipping redundant initializing to itself
        let fontRef = attributedText?.attribute(NSAttributedString.Key(kCTFontAttributeName as String), at: 0, effectiveRange: nil) as? CTFont?
        var lineHeight: CGFloat = CTFontGetSize(fontRef) + 4.0
        let settings = [alignmentSetting]
        do {
            .maximumLineHeight, MemoryLayout<CGFloat>.size, lineHeight
        }
    }
}

let kPDFPageWidth = 612
let kPDFPageHeight = 792

let kPDFFontMin = 10.0
let kPDFFontText = 12.0
let kPDFFontHeader = 20.0
let kPDFFontFooter = 11.0

let kPDFPageBorder = 50
let kPDFImageBorder = 5
let kPDFCellPadding = 0
let kPDFTableBorderWidth = 2

let kPDFTableTextColor = UIColor.black
let kPDFTableBorderColor = UIColor.black
let kPDFTableFillColor = nil
let kPDFTableHeaderFillColor = UIColor(white: 0.9, alpha: 1.0)

let kPDFTableCellSpanNone = 0
let kPDFTableCellSpanRow = 1
let kPDFTableCellSpanColumn = 2
let kPDFTableCellSpanBoth = 3
