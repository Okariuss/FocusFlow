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
    func createTestContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: FocusSession.self, UserSettings.self,
            configurations: config
        )
        return ModelContext(container)
    }
    
    @MainActor
    @Test func testInitialization() throws {
        let context = try createTestContext()
        let viewModel = AnalyticsViewModel(modelContext: context)
        
        #expect(viewModel.sessions.isEmpty)
        #expect(viewModel.selectedPeriod == .daily)
    }
    
    @MainActor
    @Test func testLoadSessions() throws {
        let context = try createTestContext()
        
        // Create sessions
        for i in 0..<5 {
            let session = FocusSession(
                startTime: Date().addingTimeInterval(TimeInterval(-i * 3600)),
                endTime: Date().addingTimeInterval(TimeInterval(-i * 3600 + 1800))
            )
            context.insert(session)
        }
        try context.save()
        
        let viewModel = AnalyticsViewModel(modelContext: context)
        
        #expect(viewModel.sessions.count == 5)
    }
    
    @MainActor
    @Test func testPeriodSelection() throws {
        let context = try createTestContext()
        let viewModel = AnalyticsViewModel(modelContext: context)
        
        // Default is daily
        #expect(viewModel.selectedPeriod == .daily)
        
        // Change to weekly
        viewModel.selectedPeriod = .weekly
        #expect(viewModel.selectedPeriod == .weekly)
        
        // Change to monthly
        viewModel.selectedPeriod = .monthly
        #expect(viewModel.selectedPeriod == .monthly)
    }
    
    @MainActor
    @Test func testTotalSessionsCount() throws {
        let context = try createTestContext()
        
        // Create 3 sessions
        for i in 0..<3 {
            let session = FocusSession(
                startTime: Date().addingTimeInterval(TimeInterval(-i * 3600)),
                endTime: Date().addingTimeInterval(TimeInterval(-i * 3600 + 1800))
            )
            context.insert(session)
        }
        try context.save()
        
        let viewModel = AnalyticsViewModel(modelContext: context)
        
        #expect(viewModel.totalSessions == 3)
    }
    
    @MainActor
    @Test func testOnlyCompletedSessionsLoaded() throws {
        let context = try createTestContext()
        
        // Create completed session
        let completed = FocusSession(
            startTime: Date().addingTimeInterval(-3600),
            endTime: Date().addingTimeInterval(-1800)
        )
        context.insert(completed)
        
        // Create incomplete session
        let incomplete = FocusSession(
            startTime: Date(),
            endTime: nil
        )
        context.insert(incomplete)
        
        try context.save()
        
        let viewModel = AnalyticsViewModel(modelContext: context)
        
        // Should only load completed session
        #expect(viewModel.sessions.count == 1)
        #expect(viewModel.sessions.first?.endTime != nil)
    }
    
    @MainActor
    @Test func testTimePeriodCases() throws {
        let periods = AnalyticsViewModel.TimePeriod.allCases
        
        #expect(periods.count == 3)
        #expect(periods.contains(.daily))
        #expect(periods.contains(.weekly))
        #expect(periods.contains(.monthly))
    }
        
    @MainActor
    @Test func testTotalFocusTimeCalculation() throws {
        let context = try createTestContext()
        
        let session1 = FocusSession(
            startTime: Date().addingTimeInterval(-7200),
            endTime: Date().addingTimeInterval(-5400) // 30 min
        )
        let session2 = FocusSession(
            startTime: Date().addingTimeInterval(-3600),
            endTime: Date().addingTimeInterval(-1800) // 30 min
        )
        
        context.insert(session1)
        context.insert(session2)
        try context.save()
        
        let viewModel = AnalyticsViewModel(modelContext: context)
        
        #expect(viewModel.totalFocusTime.contains("1h") || viewModel.totalFocusTime.contains("60m"))
    }
    
    @MainActor
    @Test func testAverageSessionLength() throws {
        let context = try createTestContext()
        
        for i in 0..<2 {
            let session = FocusSession(
                startTime: Date().addingTimeInterval(TimeInterval(-i * 7200)),
                endTime: Date().addingTimeInterval(TimeInterval(-i * 7200 + 1800))
            )
            context.insert(session)
        }
        try context.save()
        
        let viewModel = AnalyticsViewModel(modelContext: context)
        
        #expect(viewModel.averageSessionLength.contains("30m"))
    }
    
    @MainActor
    @Test func testLongestStreakConsecutiveDays() throws {
        let context = try createTestContext()
        let calendar = Calendar.current
        let today = Date()
        
        for i in 0..<3 {
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            let session = FocusSession(
                startTime: date,
                endTime: date.addingTimeInterval(1800)
            )
            context.insert(session)
        }
        try context.save()
        
        let viewModel = AnalyticsViewModel(modelContext: context)
        
        #expect(viewModel.longestStreak == 3)
    }
    
    @MainActor
    @Test func testLongestStreakWithGap() throws {
        let context = try createTestContext()
        let calendar = Calendar.current
        let today = Date()
        
        let session1 = FocusSession(
            startTime: today,
            endTime: today.addingTimeInterval(1800)
        )
        context.insert(session1)
                
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
        let session2 = FocusSession(
            startTime: twoDaysAgo,
            endTime: twoDaysAgo.addingTimeInterval(1800)
        )
        context.insert(session2)
        
        try context.save()
        
        let viewModel = AnalyticsViewModel(modelContext: context)
        
        #expect(viewModel.longestStreak == 1)
    }
    
    @MainActor
    @Test func testChartDataDaily() throws {
        let context = try createTestContext()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let session = FocusSession(
            startTime: today,
            endTime: today.addingTimeInterval(1800)
        )
        context.insert(session)
        try context.save()
        
        let viewModel = AnalyticsViewModel(modelContext: context)
        viewModel.selectedPeriod = .daily
        
        let chartData = viewModel.chartData
        
        #expect(chartData.count == 7) // 7 days
        
        let todayData = chartData.last
        #expect(todayData?.1 ?? 0 > 0)
    }
    
    @MainActor
    @Test func testChartDataWeekly() throws {
        let context = try createTestContext()
        let viewModel = AnalyticsViewModel(modelContext: context)
        
        viewModel.selectedPeriod = .weekly
        let chartData = viewModel.chartData
        
        #expect(chartData.count == 4) // 4 weeks
    }
    
    @MainActor
    @Test func testChartDataMonthly() throws {
        let context = try createTestContext()
        let viewModel = AnalyticsViewModel(modelContext: context)
        
        viewModel.selectedPeriod = .monthly
        let chartData = viewModel.chartData
        
        #expect(chartData.count == 6) // 6 months
    }
    
    @MainActor
    @Test func testEmptySessionsStats() throws {
        let context = try createTestContext()
        let viewModel = AnalyticsViewModel(modelContext: context)
        
        #expect(viewModel.totalFocusTime == "0s")
        #expect(viewModel.averageSessionLength == "0m")
        #expect(viewModel.longestStreak == 0)
        #expect(viewModel.totalSessions == 0)
    }
}
