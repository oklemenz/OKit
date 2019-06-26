//
//  XMLReader.swift
//  Swift Reuse Code
//
//  Created by Oliver Klemenz on 09.03.15.
//
//

import Foundation
import UIKit

let kXMLReaderTextNodeKey = "text"

class XMLReader: NSObject, XMLParserDelegate {
    private var dictionary: [AnyHashable] = []
    private var textString = ""
    private var xmlError: Error?

    class func dictionary(forXMLData data: Data?) throws -> [AnyHashable : Any]? {
        let reader = XMLReader()
        let rootDictionary = reader.object(with: data)
        return rootDictionary
    }

    class func dictionary(forXMLString string: String?) throws -> [AnyHashable : Any]? {
        let data: Data? = string?.data(using: .utf8)
        return try? XMLReader.dictionary(forXMLData: data)
    }

    private override init() {
        super.init()
    }

    private func object(with data: Data?) -> [AnyHashable : Any]? {
        dictionary = []
        textString = ""

        var parser: XMLParser? = nil
        if let data = data {
            parser = XMLParser(data: data)
        }
        parser?.delegate = self
        let success: Bool? = parser?.parse()

        if success ?? false {
            return dictionary[0] as? [AnyHashable : Any]
        }
        return nil
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {

        var parentDict = dictionary.last as? [AnyHashable : Any]

        var childDict: [AnyHashable: Any] = [:]
        for (k, v) in attributeDict { childDict[k] = v }

        let existingValue = parentDict?[elementName]
        if existingValue != nil {
            var array: [Any]? = nil
            if (existingValue is [AnyHashable]) {
                array = existingValue as? [AnyHashable]
            } else {
                array = []
                if let existingValue = existingValue as? AnyHashable {
                    array?.append(existingValue)
                }
                parentDict?[elementName] = array
            }
            array?.append(childDict)
        } else {
            parentDict?[elementName] = childDict
        }
        dictionary.append(childDict as! AnyHashable)
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        var dictInProgress = dictionary.last as? [AnyHashable : Any]
        if textString.count > 0 {
            dictInProgress?[kXMLReaderTextNodeKey] = textString
            textString = ""
        }
        dictionary.removeLast()
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        textString += string
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        xmlError = parseError
    }
}
