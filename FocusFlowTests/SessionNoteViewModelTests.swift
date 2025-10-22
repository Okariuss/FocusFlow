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
struct SessionNoteViewModelTests {
    
    func createTestContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: FocusSession.self, UserSettings.self, configurations: config)
        return ModelContext(container)
    }
    
    @MainActor
    @Test func testInitialization() throws {
        let context = try createTestContext()
        
        let session = FocusSession(
            startTime: Date(),
            endTime: Date().addingTimeInterval(1000),
            note: "Original note"
        )
        
        let viewModel = SessionNoteViewModel(session: session, modelContext: context)
        
        #expect(viewModel.noteText == "Original note")
        #expect(viewModel.hasChanges == false)
        #expect(viewModel.canSave == false)
    }
    
    @MainActor
    @Test func testHasChangesDetection() throws {
        let context = try createTestContext()
        
        let session = FocusSession(
            startTime: Date(),
            endTime: Date().addingTimeInterval(1000),
            note: "Original"
        )
        
        let viewModel = SessionNoteViewModel(session: session, modelContext: context)
        
        #expect(viewModel.hasChanges == false)
        
        viewModel.noteText = "Modified"
        #expect(viewModel.hasChanges == true)
        
        viewModel.noteText = "Original   "
        #expect(viewModel.hasChanges == false)
    }
    
    @MainActor
    @Test func testCanSave() throws {
        let context = try createTestContext()
        
        let session = FocusSession(
            startTime: Date(),
            endTime: Date().addingTimeInterval(1800),
            note: ""
        )
        
        let viewModel = SessionNoteViewModel(session: session, modelContext: context)
        
        // Can't save without changes
        #expect(viewModel.canSave == false)
        
        // Can save with changes
        viewModel.noteText = "New note"
        #expect(viewModel.canSave == true)
    }
    
    @MainActor
    @Test func testSaveNote() throws {
        let context = try createTestContext()
        
        let session = FocusSession(
            startTime: Date(),
            endTime: Date().addingTimeInterval(1800),
            note: ""
        )
        context.insert(session)
        try context.save()
        
        let viewModel = SessionNoteViewModel(session: session, modelContext: context)
        
        viewModel.noteText = "  New note  "
        viewModel.saveNote()
        
        // Should trim whitespace
        #expect(session.note == "New note")
    }
    
    @MainActor
    @Test func testDiscardChanges() throws {
        let context = try createTestContext()
        
        let session = FocusSession(
            startTime: Date(),
            endTime: Date().addingTimeInterval(1800),
            note: "Original"
        )
        
        let viewModel = SessionNoteViewModel(session: session, modelContext: context)
        
        viewModel.noteText = "Modified"
        #expect(viewModel.noteText == "Modified")
        
        viewModel.discardChanges()
        #expect(viewModel.noteText == "Original")
    }
    
    @MainActor
    @Test func testEmptyNoteHandling() throws {
        let context = try createTestContext()
        
        let session = FocusSession(
            startTime: Date(),
            endTime: Date().addingTimeInterval(1800),
            note: "Some note"
        )
        context.insert(session)
        try context.save()
        
        let viewModel = SessionNoteViewModel(session: session, modelContext: context)
        
        // Clear the note
        viewModel.noteText = "   "
        viewModel.saveNote()
        
        // Should save as empty string
        #expect(session.note == "")
    }
}
