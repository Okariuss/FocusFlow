//
//  Date+Extension.swift
//  FocusFlow
//
//  Created by Okan Orkun on 18.10.2025.
//

import Foundation

extension Date {
    
    static func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return date.formatDateWithStyle(dateStyle: .medium)
        }
    }
    
    static func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    static func formatDateForChart(_ date: Date, period: AnalyticsViewModel.TimePeriod) -> String {
        let formatter = DateFormatter()
        
        switch period {
        case .daily:
            formatter.dateFormat = "EEE"
        case .weekly:
            formatter.dateFormat = "w"
        case .monthly:
            formatter.dateFormat = "MMM"
        }
        
        return formatter.string(from: date)
    }
    
    func formatDateWithStyle(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style = .none) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        return formatter.string(from: self)
    }
    
    func startOfWeek(using calendar: Calendar = .current) -> Date? {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components)
    }
    
    func startOfMonth(using calendar: Calendar = .current) -> Date? {
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)
    }
    
    func weekLabel(to endDate: Date, calendar: Calendar = .current) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return "\(formatter.string(from: self))–\(formatter.string(from: calendar.date(byAdding: .day, value: -1, to: endDate)!))"
    }
    
    func monthLabel(calendar: Calendar = .current) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: self)
    }
}
