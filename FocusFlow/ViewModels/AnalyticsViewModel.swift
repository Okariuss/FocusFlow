//
//  AnalyticsViewModel.swift
//  FocusFlow
//
//  Created by Okan Orkun on 22.10.2025.
//

import Foundation
import SwiftData
import SwiftUI

protocol SessionManaging {
    var sessions: [FocusSession] { get }
    func loadSessions()
    func deleteSession(_ session: FocusSession)
}

protocol SessionStatisticsProviding {
    var totalFocusTime: String { get }
    var averageSessionLength: String { get }
    var totalSessions: Int { get }
}

protocol ChartDataProviding {
    func chartDataPoints(for period: AnalyticsViewModel.TimePeriod) -> [ChartDataPoint]
}

@MainActor
@Observable
final class AnalyticsViewModel: SessionManaging, SessionStatisticsProviding, ChartDataProviding {
    
    var sessions: [FocusSession] = []
    var selectedPeriod: TimePeriod = .daily
    
    private let persistenceService: DataPersistenceService
    private let statisticsCalculator: SessionStatisticsCalculator
    private let streakCalculator: StreakCalculating
    private let chartDataGenerator: ChartDataGenerator
    
    enum TimePeriod: String, CaseIterable, Identifiable {
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
        
        var id: String { rawValue }
    }
    
    init(
        persistenceService: DataPersistenceService,
        statisticsCalculator: SessionStatisticsCalculator = SessionStatisticsCalculator(),
        streakCalculator: StreakCalculating = StreakCalculator(),
        chartDataGenerator: ChartDataGenerator = ChartDataGenerator()
    ) {
        self.persistenceService = persistenceService
        self.statisticsCalculator = statisticsCalculator
        self.streakCalculator = streakCalculator
        self.chartDataGenerator = chartDataGenerator
        loadSessions()
    }
    
    convenience init(modelContext: ModelContext) {
        self.init(persistenceService: SwiftDataPersistenceService(modelContext: modelContext))
    }
    
    func loadSessions() {
        sessions = fetchAllCompletedSessions()
    }
    
    func deleteSession(_ session: FocusSession) {
        persistenceService.delete(session)
        
        do {
            try persistenceService.save()
            loadSessions()
        } catch {
            assertionFailure("Error deleting session: \(error)")
        }
    }
    
    // MARK: Statistics
    var totalFocusTime: String {
        statisticsCalculator
            .calculateTotalFocusTime(from: sessions)
            .formattedDuration()
    }
    
    var averageSessionLength: String {
        guard !sessions.isEmpty else { return "0s" }
        
        return statisticsCalculator
            .calculateAverageSessionLength(from: sessions)
            .formattedDuration()
    }
    
    var longestStreak: Int {
        streakCalculator.calculateLongestStreak(from: sessions)
    }
    
    var totalSessions: Int {
        sessions.count
    }
    
    // MARK: Chart Data
    var chartDataPoints: [ChartDataPoint] {
        chartDataPoints(for: selectedPeriod)
    }
    
    func chartDataPoints(for period: TimePeriod) -> [ChartDataPoint] {
        switch period {
        case .daily:
            return chartDataGenerator.generateDailyData(sessions: sessions, days: 7)
        case .weekly:
            return chartDataGenerator.generateWeeklyData(sessions: sessions, weeks: 4)
        case .monthly:
            return chartDataGenerator.generateMonthlyData(sessions: sessions, months: 6)
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
            return try persistenceService.fetch(descriptor)
        } catch {
            assertionFailure("Error loading sessions: \(error)")
            return []
        }
    }
}
