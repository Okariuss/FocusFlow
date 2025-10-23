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
        
        var daysCount: Int {
            switch self {
            case .daily: return 7
            case .weekly: return 28
            case .monthly: return 180
            }
        }
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
    
    var chartData: [(String, Int)] {
        switch selectedPeriod {
        case .daily:
            return getDailyChartData()
        case .weekly:
            return getWeeklyChartData()
        case .monthly:
            return getMonthlyChartData()
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
        guard !sessions.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        
        let sessionDates = sessions
            .map { calendar.startOfDay(for: $0.startTime) }
            .uniqued()
            .sorted(by: >)
        
        guard !sessionDates.isEmpty else { return 0 }
        
        var maxStreak = 1
        var currentStreak = 1
        
        for i in 0..<(sessionDates.count - 1) {
            let currentDate = sessionDates[i]
            let nextDate = sessionDates[i+1]
            
            if let dayDifference = calendar.dateComponents([.day], from: nextDate, to: currentDate).day,
                dayDifference == 1 {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }
        
        return maxStreak
    }
    
    func getDailyChartData() -> [(String, Int)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return (0..<7).map { daysAgo in
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
            let dateKey = Date.formatDateForChart(date, period: .daily)
            let duration = getTotalDurationForDate(date)
            
            return (dateKey, duration)
        }.reversed()
    }
    
    func getWeeklyChartData() -> [(String, Int)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return (0..<4).map { weeksAgo in
            let startOfWeek = calendar.date(byAdding: .weekOfYear, value: -weeksAgo, to: today)!
            let weekKey = "W\(4 - weeksAgo)"
            let duration = getTotalDurationForWeek(startOfWeek)
            
            return (weekKey, duration)
        }.reversed()
    }
    
    func getMonthlyChartData() -> [(String, Int)] {
        let calendar = Calendar.current
        let today = Date()
        
        return (0..<6).map { monthsAgo in
            let date = calendar.date(byAdding: .month, value: -monthsAgo, to: today)!
            let monthKey = Date.formatDateForChart(date, period: .monthly)
            let duration = getTotalDurationForMonth(date)
            
            return (monthKey, duration)
        }.reversed()
    }
    
    func getTotalDurationForDate(_ date: Date) -> Int {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return sessions
            .filter { $0.startTime >= startOfDay && $0.startTime < endOfDay }
            .reduce(0) { $0 + Int($1.duration) }
    }
    
    func getTotalDurationForWeek(_ startDate: Date) -> Int {
        let calendar = Calendar.current
        let startOfWeek = calendar.startOfDay(for: startDate)
        let endOfWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: startOfWeek)!
        
        return sessions
            .filter { $0.startTime >= startOfWeek && $0.startTime < endOfWeek }
            .reduce(0) { $0 + Int($1.duration) }
    }
    
    func getTotalDurationForMonth(_ date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        
        guard let startOfMonth = calendar.date(from: components),
              let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) else {
            return 0
        }
        
        return sessions
            .filter { $0.startTime >= startOfMonth && $0.startTime < endOfMonth }
            .reduce(0) { $0 + Int($1.duration) }
    }
}
