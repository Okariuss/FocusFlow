//
//  SessionNoteViewModelTests.swift
//  FocusFlow
//
//  Created by Okan Orkun on 22.10.2025.
//

import Testing
import Foundation
import SwiftData
@testable import FocusFlow

@Suite("Session Note ViewModel Tests")
@MainActor
struct SessionNoteViewModelTests {
    
    @Test func testInitialization() {
        let mockService = MockPersistenceService()
        let session = FocusSession(startTime: Date(), endTime: Date(), note: "Test")
        
        let viewModel = SessionNoteViewModel(
            session: session,
            persistenceService: mockService
        )
        
        #expect(viewModel.noteText == "Test")
        #expect(viewModel.hasChanges == false)
    }
    
    @Test func testHasChanges() {
        let mockService = MockPersistenceService()
        let session = FocusSession(startTime: Date(), endTime: Date(), note: "Original")
        
        let viewModel = SessionNoteViewModel(
            session: session,
            persistenceService: mockService
        )
        
        viewModel.noteText = "Modified"
        #expect(viewModel.hasChanges == true)
        #expect(viewModel.canSave == true)
    }
    
    @Test func testSaveNote() {
        let mockService = MockPersistenceService()
        let mockHaptic = MockHapticService()
        let session = FocusSession(startTime: Date(), endTime: Date(), note: "")
        
        let viewModel = SessionNoteViewModel(
            session: session,
            persistenceService: mockService,
            hapticService: mockHaptic
        )
        
        viewModel.noteText = "  New note  "
        viewModel.saveNote()
        
        #expect(session.note == "New note")
        #expect(mockService.saveCallCount == 1)
        #expect(mockHaptic.successCallCount == 1)
    }
    
    @Test func testDiscardChanges() {
        let mockService = MockPersistenceService()
        let session = FocusSession(startTime: Date(), endTime: Date(), note: "Original")
        
        let viewModel = SessionNoteViewModel(
            session: session,
            persistenceService: mockService
        )
        
        viewModel.noteText = "Modified"
        viewModel.discardChanges()
        
        #expect(viewModel.noteText == "Original")
    }
}
