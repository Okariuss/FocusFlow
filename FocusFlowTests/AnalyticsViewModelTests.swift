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
}
