//
//  XLSFileCreator.swift
//  Swift Reuse Code
//
//  Created by Oliver Klemenz on 15.02.15.
//
//

import Foundation
import UIKit

let kXLSCreateTypeGrade = 1
let kXLSCreateTypeAverageAll = 2
let kXLSCreateTypeAverageSection = 3

let kXLSCreateDataExamName = "name"
let kXLSCreateDataExamType = "type"
let kXLSCreateDataExamWeight = "weight"
let kXLSCreateDataExamAverage = "average"
let kXLSCreateDataStudentName = "name"
let kXLSCreateDataStudentExams = "exams"
let kXLSCreateDataStudentGrade = "grade"
let kXLSCreateDataStudentFormula = "formula"

class XLSFileCreator: NSObject {
    init(data: [String: Any]?) {
        super.init()
        if let data = data {
            self.data = data
        }
    }

    func create(_ filePath: String?, fileTemplate: String?) {
        let content = applyTemplate(fromFile: fileTemplate, entity: data)
        //content = XLSFileCreator.prettyPrintXML(content)
        try? content?.write(toFile: filePath ?? "", atomically: true, encoding: .utf8)
    }

    private var data: [String:Any] = [:]

    func testData() {
        let exams:[Any] = [
            [
            kXLSCreateDataExamName: "KA1",
            kXLSCreateDataExamType: NSNumber(value: kXLSCreateTypeGrade),
            kXLSCreateDataExamWeight: NSNumber(value: 2),
            kXLSCreateDataExamAverage: NSNumber(value: 4.5)
        ],
            [
            kXLSCreateDataExamName: "MD1",
            kXLSCreateDataExamType: NSNumber(value: kXLSCreateTypeGrade),
            kXLSCreateDataExamWeight: NSNumber(value: 1),
            kXLSCreateDataExamAverage: NSNumber(value: 4.5)
        ],
            [
            kXLSCreateDataExamName: "KA2",
            kXLSCreateDataExamType: NSNumber(value: kXLSCreateTypeGrade),
            kXLSCreateDataExamWeight: NSNumber(value: 2),
            kXLSCreateDataExamAverage: NSNumber(value: 4.5)
        ],
            [
            kXLSCreateDataExamName: "MD2",
            kXLSCreateDataExamType: NSNumber(value: kXLSCreateTypeGrade),
            kXLSCreateDataExamWeight: NSNumber(value: 1),
            kXLSCreateDataExamAverage: NSNumber(value: 4.5)
        ],
            [
            kXLSCreateDataExamName: "HJN",
            kXLSCreateDataExamType: NSNumber(value: kXLSCreateTypeAverageAll),
            kXLSCreateDataExamAverage: NSNumber(value: 4.5)
        ],
            [
            kXLSCreateDataExamName: "KA3",
            kXLSCreateDataExamType: NSNumber(value: kXLSCreateTypeGrade),
            kXLSCreateDataExamWeight: NSNumber(value: 2),
            kXLSCreateDataExamAverage: NSNumber(value: 4.5)
        ],
            [
            kXLSCreateDataExamName: "MD3",
            kXLSCreateDataExamType: NSNumber(value: kXLSCreateTypeGrade),
            kXLSCreateDataExamWeight: NSNumber(value: 1),
            kXLSCreateDataExamAverage: NSNumber(value: 4.5)
        ],
            [
            kXLSCreateDataExamName: "KA4",
            kXLSCreateDataExamType: NSNumber(value: kXLSCreateTypeGrade),
            kXLSCreateDataExamWeight: NSNumber(value: 2),
            kXLSCreateDataExamAverage: NSNumber(value: 4.5)
        ],
            [
            kXLSCreateDataExamName: "MD4",
            kXLSCreateDataExamType: NSNumber(value: kXLSCreateTypeGrade),
            kXLSCreateDataExamWeight: NSNumber(value: 1),
            kXLSCreateDataExamAverage: NSNumber(value: 4.5)
        ],
            [
            kXLSCreateDataExamName: "GJN",
            kXLSCreateDataExamType: NSNumber(value: kXLSCreateTypeAverageSection),
            kXLSCreateDataExamAverage: NSNumber(value: 4.5)
        ]
        ]

        /*let students:[Any] = [
            [
            kXLSCreateDataStudentName: "A",
            kXLSCreateDataStudentExams: [
            [
            kXLSCreateDataStudentGrade: NSNumber(value: 1)
        ],
            [
            kXLSCreateDataStudentGrade: NSNumber(value: 2)
        ],
            [
            kXLSCreateDataStudentGrade: NSNumber(value: 3)
        ],
            [
            kXLSCreateDataStudentGrade: NSNumber(value: 4)
        ],
            [
            kXLSCreateDataStudentGrade: NSNumber(value: 2.3333333333333335),
            kXLSCreateDataStudentFormula: examFormula(exams, position: 4) ?? 0
        ],
            [
            kXLSCreateDataStudentGrade: NSNumber(value: 5)
        ],
            [
            kXLSCreateDataStudentGrade: NSNumber(value: 6)
        ],
            [
            kXLSCreateDataStudentGrade: NSNumber(value: 7)
        ],
            [
            kXLSCreateDataStudentGrade: NSNumber(value: 8)
        ],
            [
            kXLSCreateDataStudentGrade: NSNumber(value: 6.333333333333333),
            kXLSCreateDataStudentFormula: examFormula(exams, position: 9) ?? 0
        ]
        ]
        ],
            [
            kXLSCreateDataStudentName: "B",
            kXLSCreateDataStudentExams: [
            [
            kXLSCreateDataStudentGrade: NSNumber(value: 8)
        ],
            [
            kXLSCreateDataStudentGrade: NSNumber(value: 7)
        ],
            [
            kXLSCreateDataStudentGrade: NSNumber(value: 6)
        ],
            [
            kXLSCreateDataStudentGrade: NSNumber(value: 5)
        ],
            [
            kXLSCreateDataStudentGrade: NSNumber(value: 6.666666666666667),
            kXLSCreateDataStudentFormula: examFormula(exams, position: 4) ?? 0
        ],
            [
            kXLSCreateDataStudentGrade: NSNumber(value: 4)
        ],
            [
            kXLSCreateDataStudentGrade: NSNumber(value: 3)
        ],
            [
            kXLSCreateDataStudentGrade: NSNumber(value: 2)
        ],
            [
            kXLSCreateDataStudentGrade: NSNumber(value: 1)
        ],
            [
            kXLSCreateDataStudentGrade: NSNumber(value: 2.6666666666666665),
            kXLSCreateDataStudentFormula: examFormula(exams, position: 9) ?? 0
        ]
        ]
        ]
        ]*/

        var columns: [Any] = []
        let rows: [Any] = []

        for i in 0..<exams.count + 1 {
            var exam: [String:Any]? = nil
            if i > 0 {
                exam = exams[i - 1] as? [String:Any]
            }
            let examName = exam?[kXLSCreateDataExamName] as? String
            let examType: Int = (exam?[kXLSCreateDataExamType] as? NSNumber)!.intValue
            let average = CGFloat((exam?[kXLSCreateDataExamAverage] as? NSNumber)!.floatValue)

            columns.append([
            "CAPTION_STYLE": i == 0 ? "s62" : (examType == 1 ? "s63" : "s64"),
            "CAPTION": (i == 0 ? "Name".localized : examName) ?? 0,
            "AVG_STYLE": i == 0 ? "s71" : (examType == 1 ? "s72" : "s73"),
            "AVG_TYPE": i == 0 ? "String" : "Number",
            "AVG_FORMULA": (i == 0 ? "" : avgFormula(0)) ?? 0,
            "AVG_CONTENT": i == 0 ? "Average".localized : NSNumber(value: Float(average))
                ] as [String:Any])
        }

        /*for student in students {
            var cells: [AnyHashable] = []
            for i in 0..<exams.count + 1 {
                var exam: [AnyHashable : Any]? = nil
                var studentExam: [AnyHashable : Any]? = nil
                if i > 0 {
                    exam = exams[i - 1]
                    studentExam = student[kXLSCreateDataStudentExams][i - 1] as? [AnyHashable : Any]
                }
                let examType: Int = (exam?[kXLSCreateDataExamType] as? NSNumber)?.intValue
                if let grade = (i == 0 ? student[kXLSCreateDataExamName] : studentExam?[kXLSCreateDataStudentGrade]) as? RawValueType {
                    cells.append([
                    "CONTENT_STYLE": i == 0 ? "s65" : (examType == 1 ? "s66" : "s67"),
                    "CONTENT_FORMULA": examType > 1 ? (studentExam?[kXLSCreateDataStudentFormula] as? String ?? "") : "",
                    "CONTENT_TYPE": i == 0 ? "String" : "Number",
                    "CONTENT": grade
                    ])
                }
            }
            rows.append([
            "CELL": cells
            ])
        }*/

        data = [
        "AUTHOR": "Oliver Klemenz",
        "CREATED": "2015-01-30T14:24:00Z",
        "FONT_NAME": "Calibri",
        "FONT_FAMILY": "Swiss",
        "FONT_SIZE": NSNumber(value: 12),
        "FONT_COLOR": "#000000",
        "NAME": "BAS",
        "COLUMN": columns,
        "ROW": rows,
        "COLUMN_COUNT": NSNumber(value: columns.count),
        "ROW_COUNT": NSNumber(value: rows.count + 2)
        ]
    }

    func examFormula(_ exams: [Any]?, position: Int) -> String? {
        // Example: =(RC[-4]*2+RC[-3]+RC[-2]*2+RC[-1])/(COUNT(RC[-4])*2+COUNT(RC[-3])+COUNT(RC[-2])*2+COUNT(RC[-1]))
        if (exams?.count ?? 0) <= 1 || position < 0 || position >= (exams?.count ?? 0) {
            return ""
        }
        let exam = exams?[position] as? [String:Any]
        let positionExamType: Int = (exam?[kXLSCreateDataExamType] as? NSNumber)!.intValue
        if positionExamType <= kXLSCreateTypeGrade {
            return ""
        }
        var formula = "=("
        var i = position - 1
        while i >= 0 {
            let exam = exams?[i] as? [String:Any]
            let examType: Int = (exam?[kXLSCreateDataExamType] as? NSNumber)!.intValue
            if positionExamType == kXLSCreateTypeAverageSection && examType > kXLSCreateTypeGrade {
                break
            }
            if examType == kXLSCreateTypeGrade {
                if i < position - 1 {
                    formula = formula + ("+")
                }
                let examWeight: Int = (exam?[kXLSCreateDataExamWeight] as? NSNumber)!.intValue
                formula = formula + ("RC[\(NSNumber(value: i - position))]")
                if examWeight != 0 && examWeight > 1 {
                    formula = formula + ("*\(NSNumber(value: examWeight))")
                }
            }
            i -= 1
        }
        formula = formula + (")/(")
        var j = position - 1
        while j >= 0 {
            let exam = exams?[j] as? [String:Any]
            let examType: Int = (exam?[kXLSCreateDataExamType] as? NSNumber)!.intValue
            if positionExamType == kXLSCreateTypeAverageSection && examType > kXLSCreateTypeGrade {
                break
            }
            if examType == kXLSCreateTypeGrade {
                if j < position - 1 {
                    formula = formula + ("+")
                }
                let examWeight: Int = (exam?[kXLSCreateDataExamWeight] as? NSNumber)!.intValue
                formula = formula + ("COUNT(RC[\(NSNumber(value: i - position))])")
                if examWeight != 0 && examWeight > 1 {
                    formula = formula + ("*\(NSNumber(value: examWeight))")
                }
            }
            j -= 1
        }
        return formula + (")")
    }

    func avgFormula(_ students: Int) -> String? {
        return "=AVERAGE(R[\(NSNumber(value: -students))]C:R[\(NSNumber(value: -1))]C)"
    }

    func applyTemplate(fromFile file: String?, entity: [String:Any]?) -> String? {
        let filePath = Bundle.main.path(forResource: file, ofType: "xml")
        let fileContent = try? String(contentsOfFile: filePath ?? "", encoding: .utf8)
        return applyTemplate(fileContent, entity: entity, level: 0)
    }

    
    let kXLSRepeatBeginRegEx = "\\{\\{#([a-zA-Z0-9_]*)\\}\\}"
    let kXLSRepeatEndRegEx = "\\{\\{/%@\\}\\}"
    let kXLSVariableRegEx = "\\{\\{([a-zA-Z0-9_]*)\\}\\}"
    
    func applyTemplate(_ template: String?, entity: [String:Any]?, level: Int) -> String? {
        var result = template
        let repeatBeginRegex = try? NSRegularExpression(pattern: kXLSRepeatBeginRegEx, options: [])
        var matches = repeatBeginRegex?.matches(in: result ?? "", options: [], range: NSRange(location: 0, length: result?.count ?? 0))
        while (matches?.count ?? 0) > 0 {
            let match: NSTextCheckingResult = (matches?[0])!
            let repeatStartIndex: Int = match.range.location
            let startIndex: Int = match.range.location + match.range.length
            let entityName = (result as NSString?)?.substring(with: match.range(at: 1)) ?? ""
            let repeatEntity = entity?[entityName] as? [Any]
            let repeatEndRegexString = String(format: kXLSRepeatEndRegEx, entityName)
            let repeatEndRegex = try? NSRegularExpression(pattern: repeatEndRegexString, options: [])
            matches = repeatEndRegex?.matches(in: result ?? "", options: [], range: NSRange(location: 0, length: result?.count ?? 0))
            if (matches?.count ?? 0) > 0 {
                let match: NSTextCheckingResult = (matches?[0])!
                let repeatEndIndex: Int = match.range.location + match.range.length
                let endIndex: Int = match.range.location
                let range = NSRange(location: startIndex, length: endIndex - startIndex)
                let repeatPart = ((result as NSString?)?.substring(with: range))!.trimmingCharacters(in: CharacterSet.whitespaces)
                let rest = (result as NSString?)?.substring(from: repeatEndIndex)
                result = (result as NSString?)?.substring(to: repeatStartIndex)
                for childEntity in repeatEntity as? [[String:Any]] ?? [] {
                    let recursiveResult = applyTemplate(repeatPart, entity: childEntity, level: level + 1)
                    result = result ?? "" + (recursiveResult ?? "")
                }
                result = result ?? "" + (rest ?? "")
            }
            matches = repeatBeginRegex?.matches(in: result ?? "", options: [], range: NSRange(location: 0, length: result?.count ?? 0))
        }
        let variableRegex = try? NSRegularExpression(pattern: kXLSVariableRegEx, options: [])
        matches = variableRegex?.matches(in: result ?? "", options: [], range: NSRange(location: 0, length: result?.count ?? 0))
        var i = (matches?.count ?? 0) - 1
        while i >= 0 {
            let match: NSTextCheckingResult = (matches?[i])!
            let variable = (result as NSString?)?.substring(with: match.range(at: 1))
            var value = entity?[variable ?? ""]
            if value == nil {
                value = ""
            }
            var replacedResult = (result as NSString?)?.substring(to: match.range.location) ?? ""
            replacedResult = replacedResult + ("\(value ?? "")")
            replacedResult = replacedResult + ((result as NSString?)?.substring(from: match.range.location + match.range.length) ?? "")
            result = replacedResult
            i -= 1
        }
        return result
    }
}
