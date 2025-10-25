//
//  HistoryViewModelTests.swift
//  FocusFlow
//
//  Created by Okan Orkun on 18.10.2025.
//

import Testing
import Foundation
import SwiftData
@testable import FocusFlow

@Suite("History ViewModel Tests")
@MainActor
struct HistoryViewModelTests {
    
    @Test func testInitialization() {
        let mockService = MockPersistenceService()
        let viewModel = HistoryViewModel(persistenceService: mockService)
        
        #expect(viewModel.sessions.isEmpty)
        #expect(viewModel.showDeleteConfirmation == false)
        #expect(mockService.fetchCallCount == 1)
    }
    
    @Test func testLoadSessions() {
        let mockService = MockPersistenceService()
        let session = FocusSession(startTime: Date(), endTime: Date())
        mockService.storage.append(session)
        
        let viewModel = HistoryViewModel(persistenceService: mockService)
        
        #expect(viewModel.sessions.count == 1)
    }
    
    @Test func testRequestDeleteSession() {
        let mockService = MockPersistenceService()
        let mockHaptic = MockHapticService()
        let viewModel = HistoryViewModel(
            persistenceService: mockService,
            hapticService: mockHaptic
        )
        
        let session = FocusSession(startTime: Date(), endTime: Date())
        
        viewModel.requestDeleteSession(session)
        
        #expect(viewModel.sessionToDelete != nil)
        #expect(viewModel.showDeleteConfirmation == true)
    }
    
    @Test func testConfirmDelete() {
        let mockService = MockPersistenceService()
        let mockHaptic = MockHapticService()
        let session = FocusSession(startTime: Date(), endTime: Date())
        mockService.storage.append(session)
        
        let viewModel = HistoryViewModel(
            persistenceService: mockService,
            hapticService: mockHaptic
        )
        
        viewModel.requestDeleteSession(session)
        viewModel.confirmDelete()
        
        #expect(mockService.deleteCallCount == 1)
        #expect(mockService.saveCallCount == 1)
        #expect(mockHaptic.successCallCount == 1)
        #expect(viewModel.showDeleteConfirmation == false)
    }
    
    @Test func testCancelDelete() {
        let mockService = MockPersistenceService()
        let mockHaptic = MockHapticService()
        let viewModel = HistoryViewModel(
            persistenceService: mockService,
            hapticService: mockHaptic
        )
        
        let session = FocusSession(startTime: Date(), endTime: Date())
        viewModel.requestDeleteSession(session)
        viewModel.cancelDelete()
        
        #expect(mockHaptic.lightCallCount == 1)
        #expect(viewModel.showDeleteConfirmation == false)
        #expect(viewModel.sessionToDelete == nil)
    }
    
    @Test func testSessionsByDate() {
        let mockService = MockPersistenceService()
        let today = Date()
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        let session1 = FocusSession(startTime: today, endTime: today)
        let session2 = FocusSession(startTime: yesterday, endTime: yesterday)
        
        mockService.storage.append(contentsOf: [session1, session2])
        
        let viewModel = HistoryViewModel(persistenceService: mockService)
        let grouped = viewModel.sessionsByDate()
        
        #expect(grouped.count == 2)
        #expect(grouped.first?.0 == "Today")
    }
}
