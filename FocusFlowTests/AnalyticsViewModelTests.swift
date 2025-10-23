//
//  AnalyticsViewModelTests.swift
//  FocusFlow
//
//  Created by Okan Orkun on 22.10.2025.
//

import Foundation
import SwiftData
import Testing
@testable import FocusFlow

@Suite("Analytics ViewModel Tests")
struct AnalyticsViewModelTests {
    
    // MARK: Helpers
    func createTestContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: FocusSession.self, UserSettings.self,
            configurations: config
        )
        return ModelContext(container)
    }
    
    // MARK: Initialization
    @MainActor
    @Test func testInitialization() throws {
        let context = try createTestContext()
        let viewModel = AnalyticsViewModel(modelContext: context)
        
        #expect(viewModel.sessions.isEmpty)
        #expect(viewModel.selectedPeriod == .daily)
    }
    
    // MARK: Session Loading
    @MainActor
    @Test func testLoadSessions() throws {
        let context = try createTestContext()
        
        for i in 0..<5 {
            let start = Date().addingTimeInterval(TimeInterval(-i * 3600))
            let end = start.addingTimeInterval(1800)
            let session = FocusSession(startTime: start, endTime: end)
            context.insert(session)
        }
        try context.save()
                
        let viewModel = AnalyticsViewModel(modelContext: context)
        #expect(viewModel.sessions.count == 5)
    }
    
    @MainActor
    @Test func testOnlyCompletedSessionsLoaded() throws {
        let context = try createTestContext()
        
        let completed = FocusSession(startTime: Date().addingTimeInterval(-3600),
                                     endTime: Date())
        let incomplete = FocusSession(startTime: Date(), endTime: nil)
        
        context.insert(completed)
        context.insert(incomplete)
        try context.save()
        
        let viewModel = AnalyticsViewModel(modelContext: context)
        #expect(viewModel.sessions.count == 1)
        #expect(viewModel.sessions.first?.endTime != nil)
    }
    
    // MARK: Period Selection
    @MainActor
    @Test func testPeriodSelection() throws {
        let context = try createTestContext()
        let viewModel = AnalyticsViewModel(modelContext: context)
        
        #expect(viewModel.selectedPeriod == .daily)
        
        viewModel.selectedPeriod = .weekly
        #expect(viewModel.selectedPeriod == .weekly)
        
        viewModel.selectedPeriod = .monthly
        #expect(viewModel.selectedPeriod == .monthly)
    }
    
    @MainActor
    @Test func testTimePeriodCases() throws {
        let periods = AnalyticsViewModel.TimePeriod.allCases
        #expect(periods == [.daily, .weekly, .monthly])
    }
    
    // MARK: Statistics
    @MainActor
    @Test func testTotalSessionsCount() throws {
        let context = try createTestContext()
        
        (0..<3).forEach { i in
            let start = Date().addingTimeInterval(TimeInterval(-i * 3600))
            let end = start.addingTimeInterval(1800)
            context.insert(FocusSession(startTime: start, endTime: end))
        }
        try context.save()
                
        let viewModel = AnalyticsViewModel(modelContext: context)
        
        #expect(viewModel.totalSessions == 3)
    }
    
    @MainActor
    @Test func testTotalFocusTimeCalculation() throws {
        let context = try createTestContext()
        
        let session1 = FocusSession(startTime: Date().addingTimeInterval(-7200),
                                    endTime: Date().addingTimeInterval(-5400))
        let session2 = FocusSession(startTime: Date().addingTimeInterval(-3600),
                                    endTime: Date().addingTimeInterval(-1800))
        context.insert(session1)
        context.insert(session2)
        try context.save()
        
        let viewModel = AnalyticsViewModel(modelContext: context)
        #expect(viewModel.totalFocusTime.contains("1h") || viewModel.totalFocusTime.contains("60m"))
    }
    
    @MainActor
    @Test func testAverageSessionLength() throws {
        let context = try createTestContext()
        
        (0..<2).forEach { i in
            let start = Date().addingTimeInterval(TimeInterval(-i * 7200))
            let end = start.addingTimeInterval(1800)
            context.insert(FocusSession(startTime: start, endTime: end))
        }
        try context.save()
                
        let viewModel = AnalyticsViewModel(modelContext: context)
        #expect(viewModel.averageSessionLength.contains("30m"))
    }
    
    @MainActor
    @Test func testEmptySessionsStats() throws {
        let context = try createTestContext()
        let viewModel = AnalyticsViewModel(modelContext: context)
        
        #expect(viewModel.totalFocusTime == "0s")
        #expect(viewModel.averageSessionLength == "0s")
        #expect(viewModel.longestStreak == 0)
        #expect(viewModel.totalSessions == 0)
    }
    
    // MARK: Streak Calculation
    @MainActor
    @Test func testLongestStreakConsecutiveDays() throws {
        let context = try createTestContext()
        let today = Calendar.current.startOfDay(for: Date())
        
        (0..<3).forEach { i in
            let start = Calendar.current.date(byAdding: .day, value: -i, to: today)!
            let end = start.addingTimeInterval(1800)
            context.insert(FocusSession(startTime: start, endTime: end))
        }
        try context.save()
                
        let viewModel = AnalyticsViewModel(modelContext: context)
        #expect(viewModel.longestStreak == 3)
    }
    
    @MainActor
    @Test func testLongestStreakWithGap() throws {
        let context = try createTestContext()
        let today = Calendar.current.startOfDay(for: Date())
        
        let s1 = FocusSession(startTime: today, endTime: today.addingTimeInterval(1800))
        let s2 = FocusSession(
            startTime: Calendar.current.date(byAdding: .day, value: -2, to: today)!,
            endTime: Calendar.current.date(byAdding: .day, value: -2, to: today)!.addingTimeInterval(1800)
        )
        context.insert(s1)
        context.insert(s2)
        try context.save()
        
        let viewModel = AnalyticsViewModel(modelContext: context)
        #expect(viewModel.longestStreak == 1)
    }
    
    // MARK: Chart Data
    @MainActor
    @Test func testChartDataDaily() throws {
        let context = try createTestContext()
        let today = Calendar.current.startOfDay(for: Date())
        
        let session = FocusSession(startTime: today, endTime: today.addingTimeInterval(1800))
        context.insert(session)
        try context.save()
        
        let viewModel = AnalyticsViewModel(modelContext: context)
        viewModel.selectedPeriod = .daily
        
        let chartData = viewModel.chartDataPoints
        #expect(chartData.count == 7) // 7 days
        #expect(chartData.last?.value ?? 0 > 0)
    }
    
    @MainActor
    @Test func testChartDataWeekly() throws {
        let context = try createTestContext()
        let viewModel = AnalyticsViewModel(modelContext: context)
        
        viewModel.selectedPeriod = .weekly
        let chartData = viewModel.chartDataPoints
        
        #expect(chartData.count == 4) // 4 weeks
    }
    
    @MainActor
    @Test func testChartDataMonthly() throws {
        let context = try createTestContext()
        let viewModel = AnalyticsViewModel(modelContext: context)
        
        viewModel.selectedPeriod = .monthly
        let chartData = viewModel.chartDataPoints
        
        #expect(chartData.count == 6) // 6 months
    }
}
