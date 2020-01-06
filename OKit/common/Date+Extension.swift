//
//  Date+Extension.swift
//  OKit
//
//  Created by Klemenz, Oliver on 12.03.19.
//  Copyright © 2020 Klemenz, Oliver. All rights reserved.
//

import Foundation

@objc
public extension NSDate {
    
    var formatDate: String {
        return (self as Date).formatDate
    }
    
    var formatRelativeDate: String {
        return (self as Date).formatRelativeDate
    }
    
    var formatFullDate: String {
        return (self as Date).formatFullDate
    }
    
    var formatRelativeFullDate: String {
        return (self as Date).formatRelativeFullDate
    }
    
    var formatDateTime: String {
        return (self as Date).formatDateTime
    }
    
    var formatRelativeDateTime: String {
        return (self as Date).formatRelativeDateTime
    }
    
    var formatTime: String {
        return (self as Date).formatTime
    }
    
    var formatRelativeTime: String {
        return (self as Date).formatRelativeTime
    }
    
    var formatISO: String {
        return (self as Date).formatISO
    }
    
    var formatInterval: String {
        return (self as Date).formatInterval
    }
}

public extension Date {
    
    var formatDate: String {
        return Date.dateFormatter.string(from: self as Date)
    }
    
    var formatRelativeDate: String {
        return Date.relativeDateFormatter.string(from: self as Date)
    }
    
    var formatFullDate: String {
        return Date.fullDateFormatter.string(from: self as Date)
    }
    
    var formatRelativeFullDate: String {
        return Date.relativeFullDateFormatter.string(from: self as Date)
    }
    
    var formatDateTime: String {
        return Date.dateTimeFormatter.string(from: self as Date)
    }
    
    var formatRelativeDateTime: String {
        return Date.relativeDateTimeFormatter.string(from: self as Date)
    }
    
    var formatTime: String {
        return Date.timeFormatter.string(from: self as Date)
    }
    
    var formatRelativeTime: String {
        return Date.relativeTimeFormatter.string(from: self as Date)
    }
    
    var formatISO: String {
        return Date.isoFormatter.string(from: self as Date)
    }
    
    var formatInterval: String {
        let time = Date().timeIntervalSince(self)
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    static var relativeDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
    
    static var fullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter
    }()
    
    static var relativeFullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
    
    static var dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    static let relativeDateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
    
    static var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    static let relativeTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
    
    static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate,
                                   .withTime,
                                   .withDashSeparatorInDate,
                                   .withColonSeparatorInTime]
        return formatter
    }()
    
}
