//
//  Annotation.swift
//  Swift Reuse Code
//
//  Created by Oliver Klemenz on 25.07.14.
//
//
import Foundation
import UIKit

protocol AnnotationReminderLesson: class {
    func date(forReminderLesson reminderLesson: NSObject?) -> Date?
}

class Annotation: NSObject, AnnotationReminderLesson {
    var type: Int = 0
    var dataAttachmentUUID = ""
    var thumbnailAttachmentUUID = ""
    var length: Int64 = 0
    var reminderDate: Date?
    var reminderOffset: DateComponents?
    var reminderFireDate: Date?
    var reminder: UILocalNotification?

    convenience init(type: Int, data: Data?, thumbnail: Data?, length: Int) {
        self.init()
        self.type = type
        update(data, thumbnail: thumbnail, length: length)
    }

    func data() -> Data? {
        if dataAttachmentUUID != "" {
        }
        return nil
    }

    func thumbnail() -> Data? {
        if thumbnailAttachmentUUID != "" {
        }
        return nil
    }

    func update(_ data: Data?, thumbnail: Data?, length: Int) {
        if dataAttachmentUUID == "" && data != nil {
        } else if dataAttachmentUUID != "" {
        }
        if thumbnailAttachmentUUID == "" && thumbnail != nil {
        } else if thumbnailAttachmentUUID != "" {
        }
    }

    func text() -> String? {
        if type == 0 {
            if let data = data() {
                return String(data: data, encoding: .utf8)
            }
            return nil
        }
        return nil
    }

    func image() -> UIImage? {
        if type == 1 || type == 2 {
            if let data = data() {
                return UIImage(data: data)
            }
            return nil
        }
        return nil
    }

    func iconImage() -> UIImage? {
        var iconImage: UIImage? = nil
        if type == 1 || type == 2 {
            if let thumbnail = thumbnail() {
                iconImage = UIImage(data: thumbnail)
            }
        } else if type == 3 {
            iconImage = UIImage(named: "audio")
        } else if type == 4 {
            iconImage = UIImage(named: "text")
        } else if type == 5 {
            if let thumbnail = thumbnail() {
                iconImage = UIImage(data: thumbnail)
            }
        }
        return iconImage
    }

    func title() -> String? {
        var title = ""
        if type == 1 || type == 2 {
            title = "\("File Size".localized): \(Utilities.formatFileSize(Int64(length)) ?? "")"
        } else if type == 3 {
            title = "\("Duration".localized): \(Utilities.formatSecondsText(Int(length)) ?? "")"
        } else if type == 4 {
            title = text()?.replacingOccurrences(of: "\n", with: " ") ?? ""
        } else if type == 5 {
            title = "\("Duration".localized): \(Utilities.formatSeconds(Int(length)) ?? "")"
        }
        return title
    }

    func subTitle() -> String? {
        return nil
    }

    func reminderFire(_ date: Date?, offset: DateComponents?) -> Date? {
        let calendar: Calendar? = Utilities.calendar()
        var dateComponents: DateComponents? = nil
        if let date = date {
            dateComponents = calendar?.dateComponents([.year, .month, .day], from: date)
        }
        var timeComponents: DateComponents? = nil
        if let date = date {
            timeComponents = calendar?.dateComponents([.hour, .minute], from: date)
        }
        var components = DateComponents()
        components.day = dateComponents?.day ?? 0
        components.month = dateComponents?.month ?? 0
        components.year = dateComponents?.year ?? 0
        components.hour = timeComponents?.hour ?? 0
        components.minute = timeComponents?.minute ?? 0

        var fireDate: Date? = calendar?.date(from: components)
        if offset != nil {
            if let offset = offset, let _fireDate = fireDate {
                fireDate = calendar?.date(byAdding: offset, to: _fireDate)
            }
        }
        if let fireDate = fireDate {
            if Date().compare(fireDate) == .orderedAscending {
                return fireDate
            }
        }
        return nil
    }

    func scheduleReminder(_ reminderDate: Date?, offset reminderOffset: DateComponents?) {
        unscheduleReminder()
        let fireDate: Date? = reminderFire(reminderDate, offset: reminderOffset)
        if fireDate != nil {
            let localNotification = UILocalNotification()
            localNotification.fireDate = fireDate
            localNotification.timeZone = NSTimeZone.default
            localNotification.alertBody = "You have set a reminder for an annotation.".localized
            localNotification.alertAction = "View".localized
            localNotification.soundName = UILocalNotificationDefaultSoundName
            localNotification.applicationIconBadgeNumber = 1

            UIApplication.shared.scheduleLocalNotification(localNotification)
        }
    }

    func unscheduleReminder() {
        if reminder != nil {
            if let reminder = reminder {
                UIApplication.shared.cancelLocalNotification(reminder)
            }
        }
    }

    func isReminderActive() -> Bool {
        return reminderFire(reminderDate, offset: reminderOffset) != nil
    }

    func cleanup() {
        if dataAttachmentUUID != "" {
        }
        if thumbnailAttachmentUUID != "" {
        }
    }

    func date(forReminderLesson reminderLesson: NSObject?) -> Date? {
        return nil
    }

    func entity() -> NSObject? {
        return nil
    }
}
