//
//  SessionNoteViewModel.swift
//  FocusFlow
//
//  Created by Okan Orkun on 21.10.2025.
//

import Foundation
import SwiftData
import UIKit

@MainActor
@Observable
final class SessionNoteViewModel {
    var noteText: String
    let session: FocusSession
    
    private let persistenceService: DataPersistenceService
    private let hapticService: HapticFeedbackProviding
    private let originalNote: String
    
    // MARK: Computed Properties
    var hasChanges: Bool {
        noteText.trimmingCharacters(in: .whitespacesAndNewlines) != originalNote
    }
    
    var canSave: Bool {
        hasChanges
    }
    
    init(
        session: FocusSession,
        persistenceService: DataPersistenceService,
        hapticService: HapticFeedbackProviding = HapticFeedbackService(),
    ) {
        self.session = session
        self.persistenceService = persistenceService
        self.hapticService = hapticService
        self.noteText = session.note
        self.originalNote = session.note
    }
    
    convenience init(session: FocusSession, modelContext: ModelContext) {
        self.init(session: session, persistenceService: SwiftDataPersistenceService(modelContext: modelContext))
    }
    
    // MARK: Actions
    func saveNote() {
        let trimmedNote = noteText.trimmingCharacters(in: .whitespacesAndNewlines)
        session.note = trimmedNote
        
        do {
            try persistenceService.save()
            hapticService.success()
        } catch {
            assertionFailure("Error saving note: \(error)")
        }
    }
    
    func discardChanges() {
        noteText = originalNote
    }
}
