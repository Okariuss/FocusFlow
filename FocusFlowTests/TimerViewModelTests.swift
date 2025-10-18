//
//  TimerViewModelTests.swift
//  FocusFlow
//
//  Created by Okan Orkun on 17.10.2025.
//

import Testing
import Foundation
import SwiftData
@testable import FocusFlow

@Suite("Timer ViewModel Tests")
struct TimerViewModelTests {

    private func createTestContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: FocusSession.self, UserSettings.self,
            configurations: config
        )
        return ModelContext(container)
    }

    @Test func testViewModelInitialization() throws {
        let context = try createTestContext()
        let viewModel = TimerViewModel(modelContext: context)
        
        #expect(viewModel.currentSession == nil)
        #expect(viewModel.elapsedTime == 0)
        #expect(viewModel.isSessionActive == false)
        #expect(viewModel.formattedTime == "00:00:00")
        #expect(viewModel.statusText == "Ready to focus")
    }
    
    @Test func testStartSession() throws {
        let context = try createTestContext()
        let viewModel = TimerViewModel(modelContext: context)
        
        viewModel.startSession()
        
        #expect(viewModel.currentSession != nil)
        #expect(viewModel.isSessionActive)
        #expect(viewModel.statusText == "Focusing...")
        #expect(viewModel.elapsedTime == 0)
    }
    
    @Test func testStopSession() throws {
        let context = try createTestContext()
        let viewModel = TimerViewModel(modelContext: context)
        
        viewModel.startSession()
        let session = viewModel.currentSession
        
        viewModel.stopSession()
        
        #expect(viewModel.currentSession == nil)
        #expect(viewModel.isSessionActive == false)
        #expect(viewModel.elapsedTime == 0)
        #expect(session?.endTime != nil)
    }
    
    @Test func testFormattedTime() throws {
        let context = try createTestContext()
        let viewModel = TimerViewModel(modelContext: context)
        
        viewModel.elapsedTime = 0
        #expect(viewModel.formattedTime == "00:00:00")
        
        viewModel.elapsedTime = 65
        #expect(viewModel.formattedTime == "00:01:05")
        
        viewModel.elapsedTime = 3661
        #expect(viewModel.formattedTime == "01:01:01")
        
        viewModel.elapsedTime = 3599
        #expect(viewModel.formattedTime == "00:59:59")
    }
    
    @Test func testCannotStartMultipleSessions() throws {
        let context = try createTestContext()
        let viewModel = TimerViewModel(modelContext: context)
        
        viewModel.startSession()
        let firstSession = viewModel.currentSession
        
        viewModel.startSession()
        let secondSession = viewModel.currentSession
        
        #expect(firstSession === secondSession)
    }
    
    @Test func testSessionSavedToDatabase() throws {
        let context = try createTestContext()
        let viewModel = TimerViewModel(modelContext: context)
        
        viewModel.startSession()
        viewModel.stopSession()
        
        let descriptor = FetchDescriptor<FocusSession>()
        let sessions = try context.fetch(descriptor)
        
        #expect(sessions.count == 1)
        #expect(sessions.first?.endTime != nil)
    }
    
    @Test func testMultipleSessionsSaved() throws {
        let context = try createTestContext()
        let viewModel = TimerViewModel(modelContext: context)
        
        for _ in 0..<3 {
            viewModel.startSession()
            viewModel.stopSession()
        }
        
        let descriptor = FetchDescriptor<FocusSession>()
        let sessions = try context.fetch(descriptor)
        
        #expect(sessions.count == 3)
        
        for session in sessions {
            #expect(session.endTime != nil)
        }
    }
    
    @Test func testTodaysTotalInitiallyZero() throws {
        let context = try createTestContext()
        let viewModel = TimerViewModel(modelContext: context)
        
        #expect(viewModel.todaysTotalMinutes == 0)
        #expect(viewModel.todaysTotalFormatted == "0m")
    }
    
    @Test func testTodaysTotalWithCompletedSessions() throws {
        let context = try createTestContext()
        
        let session1 = FocusSession(
            startTime: Date().addingTimeInterval(-3600), // 1 hour ago
            endTime: Date().addingTimeInterval(-2400) // stopped 40 min ago (20 min session)
        )
        context.insert(session1)
        
        let session2 = FocusSession(
            startTime: Date().addingTimeInterval(-1800), // 30 min ago
            endTime: Date().addingTimeInterval(-600) // stopped 10 min ago (20 min session)
        )
        context.insert(session2)
        
        try context.save()
        
        let viewModel = TimerViewModel(modelContext: context)
        
        #expect(viewModel.todaysTotalMinutes == 40)
        #expect(viewModel.todaysTotalFormatted == "40m")
    }
    
    @Test func testTodaysTotalWithActiveSession() throws {
        let context = try createTestContext()
        let viewModel = TimerViewModel(modelContext: context)
        
        viewModel.startSession()
        
        viewModel.elapsedTime = 300 // 5 min
        
        #expect(viewModel.todaysTotalMinutes == 5)
        #expect(viewModel.todaysTotalFormatted == "5m")
    }
    
    @Test func testTodaysTotalFormatting() throws {
        let context = try createTestContext()
        
        let testCases: [(TimeInterval, String)] = [
            (0, "0m"),
            (30 * 60, "30m"),
            (59 * 60, "59m"),
            (60 * 60, "1h"),
            (90 * 60, "1h 30m"),
            (125 * 60, "2h 5m"),
            (180 * 60, "3h")
        ]
        
        for (duration, expected) in testCases {
            let session = FocusSession(
                startTime: Date().addingTimeInterval(-duration),
                endTime: Date()
            )
            context.insert(session)
            try context.save()
            
            let viewModel = TimerViewModel(modelContext: context)
            #expect(viewModel.todaysTotalFormatted == expected)
            
            context.delete(session)
            try context.save()
        }
    }
    
    @Test func testOnlyTodaysSessionsCounted() throws {
        let context = try createTestContext()
        
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
        
        let oldSession = FocusSession(
            startTime: yesterday,
            endTime: yesterday.addingTimeInterval(3600) // 1 hour session
        )
        context.insert(oldSession)
        
        let todaySession = FocusSession(
            startTime: Date().addingTimeInterval(-1800),
            endTime: Date() // 30 min session
        )
        context.insert(todaySession)
        
        try context.save()
        
        let viewModel = TimerViewModel(modelContext: context)
        
        #expect(viewModel.todaysTotalMinutes == 30)
    }
    
    @Test func testPauseSession() throws {
        let context = try createTestContext()
        let viewModel = TimerViewModel(modelContext: context)
        
        viewModel.startSession()
        #expect(viewModel.isPaused == false)
        
        viewModel.pauseSession()
        
        #expect(viewModel.isPaused == true)
        #expect(viewModel.statusText == "Paused")
        #expect(viewModel.currentSession?.pauseCount == 1)
    }
    
    @Test func testResumeSession() throws {
        let context = try createTestContext()
        let viewModel = TimerViewModel(modelContext: context)
        
        viewModel.startSession()
        viewModel.pauseSession()
        #expect(viewModel.isPaused == true)
        
        viewModel.resumeSession()
        
        #expect(viewModel.isPaused == false)
        #expect(viewModel.statusText == "Focusing...")
    }
    
    @MainActor
    @Test func testPausedDurationTracking() async throws {
        let context = try createTestContext()
        let viewModel = TimerViewModel(modelContext: context)
        
        viewModel.startSession()
        let session = viewModel.currentSession!
        
        viewModel.pauseSession()
        
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        viewModel.resumeSession()
        
        // Paused duration should be approximately 2 seconds (allow 0.5s tolerance)
        #expect(session.totalPauseDuration >= 1.5)
        #expect(session.totalPauseDuration <= 2.5)
    }
    
    @MainActor
    @Test func testMultiplePauses() async throws {
        let context = try createTestContext()
        let viewModel = TimerViewModel(modelContext: context)
        
        viewModel.startSession()
        let session = viewModel.currentSession!
        
        viewModel.pauseSession()
        try await Task.sleep(nanoseconds: 1_000_000_000)
        viewModel.resumeSession()
        
        viewModel.pauseSession()
        try await Task.sleep(nanoseconds: 1_000_000_000)
        viewModel.resumeSession()
        
        #expect(session.pauseCount == 2)
        // Total paused duration should be approximately 2 seconds (allow 1s tolerance)
        #expect(session.totalPauseDuration >= 1.0)
        #expect(session.totalPauseDuration <= 3.0)
    }
    
    @Test func testPausedTimeExcludedFromDuration() throws {
        let context = try createTestContext()
        
        let startTime = Date()
        let session = FocusSession(startTime: startTime)
        
        session.endTime = startTime.addingTimeInterval(150)
        session.totalPauseDuration = 30
        
        #expect(session.duration == 120)
        #expect(session.durationInMinutes == 2)
    }
    
    @Test func testCannotPauseInactiveSession() throws {
        let context = try createTestContext()
        let viewModel = TimerViewModel(modelContext: context)
        
        viewModel.pauseSession()
        
        #expect(viewModel.isPaused == false)
        #expect(viewModel.currentSession == nil)
    }
    
    @Test func testCannotResumeUnpausedSession() throws {
        let context = try createTestContext()
        let viewModel = TimerViewModel(modelContext: context)
        
        viewModel.startSession()
        let initialPauseCount = viewModel.currentSession?.pauseCount ?? 0
        
        viewModel.resumeSession()
        
        #expect(viewModel.isPaused == false)
        #expect(viewModel.currentSession?.pauseCount == initialPauseCount)
    }
    
    @MainActor
    @Test func testStoppingWhilePaused() async throws {
        let context = try createTestContext()
        let viewModel = TimerViewModel(modelContext: context)
        
        viewModel.startSession()
        
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        viewModel.pauseSession()
        
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        viewModel.stopSession()
        
        #expect(viewModel.currentSession == nil)
        #expect(viewModel.isPaused == false)
        #expect(viewModel.isSessionActive == false)
    }
}
