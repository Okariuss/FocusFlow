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
struct HistoryViewModelTests {
    
    private func createTestContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: FocusSession.self, UserSettings.self,
            configurations: config
        )
        return ModelContext(container)
    }
    
    @MainActor
    @Test func testInitializationEmpty() throws {
        let context = try createTestContext()
        let viewModel = HistoryViewModel(modelContext: context)
        
        #expect(viewModel.sessions.isEmpty)
    }
    
    @MainActor
    @Test func testLoadCompletedSessions() throws {
        let context = try createTestContext()
        
        let session1 = FocusSession(
            startTime: Date().addingTimeInterval(-3600),
            endTime: Date().addingTimeInterval(-1800)
        )
        let session2 = FocusSession(
            startTime: Date().addingTimeInterval(-1800),
            endTime: Date().addingTimeInterval(-900)
        )
        
        context.insert(session1)
        context.insert(session2)
        try context.save()
        
        let viewModel = HistoryViewModel(modelContext: context)
        
        #expect(viewModel.sessions.count == 2)
    }
    
    @MainActor
    @Test func testDoesNotLoadIncompleteSessions() throws {
        let context = try createTestContext()
        
        let completed = FocusSession(
            startTime: Date().addingTimeInterval(-3600),
            endTime: Date().addingTimeInterval(-1800)
        )
        
        let incomplete = FocusSession(
            startTime: Date(),
            endTime: nil
        )
        
        context.insert(completed)
        context.insert(incomplete)
        try context.save()
        
        let viewModel = HistoryViewModel(modelContext: context)
        
        #expect(viewModel.sessions.count == 1)
        #expect(viewModel.sessions.first?.endTime != nil)
    }
    
    @MainActor
    @Test func testSessionsSortedByDate() throws {
        let context = try createTestContext()
        
        let oldSession = FocusSession(
            startTime: Date().addingTimeInterval(-7200),
            endTime: Date().addingTimeInterval(-5400)
        )
        let recentSession = FocusSession(
            startTime: Date().addingTimeInterval(-1800),
            endTime: Date().addingTimeInterval(-900)
        )
        
        context.insert(oldSession)
        context.insert(recentSession)
        try context.save()
        
        let viewModel = HistoryViewModel(modelContext: context)
        
        #expect(viewModel.sessions.first?.startTime == recentSession.startTime)
        #expect(viewModel.sessions.last?.startTime == oldSession.startTime)
    }
    
    @MainActor
    @Test func testDeleteSession() throws {
        let context = try createTestContext()
        
        let session = FocusSession(
            startTime: Date().addingTimeInterval(-3600),
            endTime: Date().addingTimeInterval(-1800)
        )
        context.insert(session)
        try context.save()
        
        let viewModel = HistoryViewModel(modelContext: context)
        #expect(viewModel.sessions.count == 1)
        
        viewModel.deleteSession(session)
        
        #expect(viewModel.sessions.isEmpty)
    }
    
    @MainActor
    @Test func testSessionsByDate() throws {
        let context = try createTestContext()
        
        let todaySession = FocusSession(
            startTime: Date(),
            endTime: Date().addingTimeInterval(1800)
        )
        
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let yesterdaySession = FocusSession(
            startTime: yesterday,
            endTime: yesterday.addingTimeInterval(1800)
        )
        
        context.insert(todaySession)
        context.insert(yesterdaySession)
        try context.save()
        
        let viewModel = HistoryViewModel(modelContext: context)
        let grouped = viewModel.sessionsByDate()
        
        #expect(grouped.count == 2)
        #expect(grouped[0].0 == "Today")
        #expect(grouped[0].1.count == 1)
        #expect(grouped[1].0 == "Yesterday")
        #expect(grouped[1].1.count == 1)
    }
    
    @MainActor
    @Test func testMultipleSessionsSameDay() throws {
        let context = try createTestContext()
        
        for i in 0..<3 {
            let session = FocusSession(
                startTime: Date().addingTimeInterval(TimeInterval(-i * 1800)),
                endTime: Date().addingTimeInterval(TimeInterval(-i * 1800 + 900))
            )
            context.insert(session)
        }
        try context.save()
        
        let viewModel = HistoryViewModel(modelContext: context)
        let grouped = viewModel.sessionsByDate()
        
        #expect(grouped.count == 1)
        #expect(grouped[0].0 == "Today")
        #expect(grouped[0].1.count == 3)
    }
    
    @MainActor
    @Test func testRequestDeleteSession() throws {
        let context = try createTestContext()
        
        let session = FocusSession(
            startTime: Date().addingTimeInterval(-3600),
            endTime: Date().addingTimeInterval(-1800)
        )
        context.insert(session)
        try context.save()
        
        let viewModel = HistoryViewModel(modelContext: context)
        
        // Initially no deletion pending
        #expect(viewModel.sessionToDelete == nil)
        #expect(viewModel.showDeleteConfirmation == false)
        
        // Request deletion
        viewModel.requestDeleteSession(session)
        
        // Should set up for confirmation
        #expect(viewModel.sessionToDelete != nil)
        #expect(viewModel.sessionToDelete?.id == session.id)
        #expect(viewModel.showDeleteConfirmation == true)
    }
    
    @MainActor
    @Test func testConfirmDelete() throws {
        let context = try createTestContext()
        
        let session = FocusSession(
            startTime: Date().addingTimeInterval(-3600),
            endTime: Date().addingTimeInterval(-1800)
        )
        context.insert(session)
        try context.save()
        
        let viewModel = HistoryViewModel(modelContext: context)
        #expect(viewModel.sessions.count == 1)
        
        // Request and confirm deletion
        viewModel.requestDeleteSession(session)
        viewModel.confirmDelete()
        
        // Session should be deleted
        #expect(viewModel.sessions.isEmpty)
        #expect(viewModel.sessionToDelete == nil)
        #expect(viewModel.showDeleteConfirmation == false)
    }
    
    @MainActor
    @Test func testCancelDelete() throws {
        let context = try createTestContext()
        
        let session = FocusSession(
            startTime: Date().addingTimeInterval(-3600),
            endTime: Date().addingTimeInterval(-1800)
        )
        context.insert(session)
        try context.save()
        
        let viewModel = HistoryViewModel(modelContext: context)
        #expect(viewModel.sessions.count == 1)
        
        // Request and cancel deletion
        viewModel.requestDeleteSession(session)
        viewModel.cancelDelete()
        
        // Session should remain
        #expect(viewModel.sessions.count == 1)
        #expect(viewModel.sessionToDelete == nil)
        #expect(viewModel.showDeleteConfirmation == false)
    }
    
    @MainActor
    @Test func testMultipleDeleteRequests() throws {
        let context = try createTestContext()
        
        let session1 = FocusSession(
            startTime: Date().addingTimeInterval(-7200),
            endTime: Date().addingTimeInterval(-5400)
        )
        let session2 = FocusSession(
            startTime: Date().addingTimeInterval(-3600),
            endTime: Date().addingTimeInterval(-1800)
        )
        
        context.insert(session1)
        context.insert(session2)
        try context.save()
        
        let viewModel = HistoryViewModel(modelContext: context)
        #expect(viewModel.sessions.count == 2)
        
        // Request delete for session1
        viewModel.requestDeleteSession(session1)
        #expect(viewModel.sessionToDelete?.id == session1.id)
        
        // Request delete for session2 (should replace)
        viewModel.requestDeleteSession(session2)
        #expect(viewModel.sessionToDelete?.id == session2.id)
        
        // Confirm deletion
        viewModel.confirmDelete()
        
        // Only session2 should be deleted
        #expect(viewModel.sessions.count == 1)
        #expect(viewModel.sessions.first?.id == session1.id)
    }
    
    @MainActor
    @Test func testDeleteStateReset() throws {
        let context = try createTestContext()
        
        let session = FocusSession(
            startTime: Date().addingTimeInterval(-3600),
            endTime: Date().addingTimeInterval(-1800)
        )
        context.insert(session)
        try context.save()
        
        let viewModel = HistoryViewModel(modelContext: context)
        
        // Set up deletion
        viewModel.requestDeleteSession(session)
        #expect(viewModel.sessionToDelete != nil)
        #expect(viewModel.showDeleteConfirmation == true)
        
        // Confirm deletion
        viewModel.confirmDelete()
        
        // State should be reset
        #expect(viewModel.sessionToDelete == nil)
        #expect(viewModel.showDeleteConfirmation == false)
    }
}
