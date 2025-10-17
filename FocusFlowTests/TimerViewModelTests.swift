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
}
