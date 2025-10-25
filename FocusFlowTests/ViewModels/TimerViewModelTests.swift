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
    
    @Test func testInitialization() {
        let mockService = MockPersistenceService()
        let viewModel = TimerViewModel(persistenceService: mockService)
        
        #expect(viewModel.currentSession == nil)
        #expect(viewModel.elapsedTime == 0)
        #expect(viewModel.isPaused == false)
        #expect(viewModel.isSessionActive == false)
    }
    
    @Test func testStartSession() {
        let mockService = MockPersistenceService()
        let viewModel = TimerViewModel(persistenceService: mockService)
        
        viewModel.startSession()
        
        #expect(viewModel.currentSession != nil)
        #expect(viewModel.isSessionActive == true)
        #expect(mockService.insertCallCount == 1)
    }
    
    @Test func testStopSession() async throws {
        let mockService = MockPersistenceService()
        let viewModel = TimerViewModel(persistenceService: mockService)
        
        viewModel.startSession()
        
        // Wait a bit
        try await Task.sleep(nanoseconds: 100_000_000)
        
        viewModel.stopSession()
        
        #expect(viewModel.currentSession == nil)
        #expect(viewModel.isSessionActive == false)
        #expect(mockService.saveCallCount == 1)
    }
    
    @Test func testPauseResume() {
        let mockService = MockPersistenceService()
        let viewModel = TimerViewModel(persistenceService: mockService)
        
        viewModel.startSession()
        #expect(viewModel.isPaused == false)
        
        viewModel.pauseSession()
        #expect(viewModel.isPaused == true)
        
        viewModel.resumeSession()
        #expect(viewModel.isPaused == false)
    }
    
    @Test func testFormattedTime() {
        let mockService = MockPersistenceService()
        let viewModel = TimerViewModel(persistenceService: mockService)
        
        viewModel.elapsedTime = 3665 // 1h 1m 5s
        #expect(viewModel.formattedTime == "01:01:05")
    }
    
    @Test func testStatusText() {
        let mockService = MockPersistenceService()
        let viewModel = TimerViewModel(persistenceService: mockService)
        
        #expect(viewModel.statusText == "Ready to focus")
        
        viewModel.startSession()
        #expect(viewModel.statusText == "Focusing...")
        
        viewModel.pauseSession()
        #expect(viewModel.statusText == "Paused")
    }
}
