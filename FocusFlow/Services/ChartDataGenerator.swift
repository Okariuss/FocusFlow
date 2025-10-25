//
//  ChartDataGenerator.swift
//  FocusFlow
//
//  Created by Okan Orkun on 24.10.2025.
//

import Foundation

final class ChartDataGenerator {
    private let calendar: Calendar
    
    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }
    
    func generateDailyData(sessions: [FocusSession], days: Int) -> [ChartDataPoint] {
        let today = calendar.startOfDay(for: Date())
        
        return (0..<days).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today),
                  let nextDay = calendar.date(byAdding: .day, value: 1, to: date) else { return nil }
            
            let value = totalDuration(from: sessions, start: date, end: nextDay)
            let label = Date.formatDateForChart(date, period: .daily)
            
            return ChartDataPoint(label: label, value: value, date: date)
        }.reversed()
    }
    
    func generateWeeklyData(sessions: [FocusSession], weeks: Int) -> [ChartDataPoint] {
        guard let currentWeekStart = Date().startOfWeek(using: calendar) else { return [] }
        
        return (0..<weeks).compactMap { offset in
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: -offset, to: currentWeekStart),
                  let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) else { return nil }
            
            let value = totalDuration(from: sessions, start: weekStart, end: weekEnd)
            let label = weekStart.weekLabel(to: weekEnd, calendar: calendar)
            
            return ChartDataPoint(label: label, value: value, date: weekStart)
        }.reversed()
    }
    
    func generateMonthlyData(sessions: [FocusSession], months: Int) -> [ChartDataPoint] {
        guard let currentMonthStart = Date().startOfMonth(using: calendar) else { return [] }
        
        return (0..<months).compactMap { offset in
            guard let monthStart = calendar.date(byAdding: .month, value: -offset, to: currentMonthStart),
                  let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) else { return nil }
            
            let value = totalDuration(from: sessions, start: monthStart, end: monthEnd)
            let label = monthStart.monthLabel(calendar: calendar)
            
            return ChartDataPoint(label: label, value: value, date: monthStart)
        }.reversed()
    }
    
    private func totalDuration(from sessions: [FocusSession], start: Date, end: Date) -> Int {
        sessions
            .filter { $0.startTime >= start && $0.startTime < end }
            .reduce(0) { $0 + Int($1.duration) }
    }
}
