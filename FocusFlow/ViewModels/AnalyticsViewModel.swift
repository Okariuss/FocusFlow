//
//  AnalyticsViewModel.swift
//  FocusFlow
//
//  Created by Okan Orkun on 22.10.2025.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable
final class AnalyticsViewModel {
    var sessions: [FocusSession] = []
    var selectedPeriod: TimePeriod = .daily
    
    private var modelContext: ModelContext
    
    enum TimePeriod: String, CaseIterable, Identifiable {
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
        
        var id: String { rawValue }
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadSessions()
    }
    
    func loadSessions() {
        sessions = fetchAllCompletedSessions()
    }
    
    var totalFocusTime: String {
        let totalSeconds = calculateTotalFocusTime()
        return totalSeconds.formattedDuration()
    }
    
    var averageSessionLength: String {
        guard !sessions.isEmpty else { return "0s" }
        
        let totalSeconds = calculateTotalFocusTime()
        let averageSeconds = totalSeconds / sessions.count
        
        return averageSeconds.formattedDuration()
    }
    
    var longestStreak: Int {
        calculateLongestStreak()
    }
    
    var totalSessions: Int {
        sessions.count
    }
    
    var chartDataPoints: [ChartDataPoint] {
        switch selectedPeriod {
        case .daily:
            return chartDataPointsForLast(days: 7)
        case .weekly:
            return weeklyChartDataPoints(lastWeeks: 4)
        case .monthly:
            return monthlyChartDataPoints(lastMonths: 6)
        }
    }
}

private extension AnalyticsViewModel {
    func fetchAllCompletedSessions() -> [FocusSession] {
        let descriptor = FetchDescriptor<FocusSession>(
            predicate: #Predicate { session in
                session.endTime != nil
            },
            sortBy: [SortDescriptor(\.startTime, order: .reverse)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            assertionFailure("Error loading sessions: \(error)")
            return []
        }
    }
    
    func calculateTotalFocusTime() -> Int {
        sessions.reduce(0) { total, session in
            total + Int(session.duration)
        }
    }
    
    func calculateLongestStreak() -> Int {
        let calendar = Calendar.current
        
        let sessionDates = sessions
            .map { calendar.startOfDay(for: $0.startTime) }
            .uniqued()
            .sorted(by: >)
        
        guard !sessionDates.isEmpty else { return 0 }
        
        var maxStreak = 1
        var currentStreak = 1
        
        for i in 0..<(sessionDates.count - 1) {
            if let dayDifference = calendar.dateComponents([.day], from: sessionDates[i+1], to: sessionDates[i]).day,
                dayDifference == 1 {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }
        
        return maxStreak
    }
    
    func chartDataPointsForLast(days: Int) -> [ChartDataPoint] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return (0..<days).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let value = totalDuration(from: date, to: calendar.date(byAdding: .day, value: 1, to: date)!)
            let label = Date.formatDateForChart(date, period: .daily)
            return ChartDataPoint(label: label, value: value, date: date)
        }.reversed()
    }
    
    func weeklyChartDataPoints(lastWeeks: Int) -> [ChartDataPoint] {
        let calendar = Calendar.current
        guard let currentWeekStart = Date().startOfWeek(using: calendar) else { return [] }
        
        return (0..<lastWeeks).compactMap { offset in
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: -offset, to: currentWeekStart),
                  let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) else { return nil }
            
            let value = totalDuration(from: weekStart, to: weekEnd)
            let label = weekStart.weekLabel(to: weekEnd, calendar: calendar)
            return ChartDataPoint(label: label, value: value, date: weekStart)
        }.reversed()
    }
    
    func monthlyChartDataPoints(lastMonths: Int) -> [ChartDataPoint] {
        let calendar = Calendar.current
        guard let currentMonthStart = Date().startOfMonth(using: calendar) else { return [] }
        
        return (0..<lastMonths).compactMap { offset in
            guard let monthStart = calendar.date(byAdding: .month, value: -offset, to: currentMonthStart),
                  let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) else { return nil }
            
            let value = totalDuration(from: monthStart, to: monthEnd)
            let label = monthStart.monthLabel(calendar: calendar)
            return ChartDataPoint(label: label, value: value, date: monthStart)
        }.reversed()
    }
    
    func totalDuration(from start: Date, to end: Date) -> Int {
        sessions.filter { $0.startTime >= start && $0.startTime < end }
            .reduce(0) { $0 + Int($1.duration) }
    }
}
