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
    var session: FocusSession
    
    private var modelContext: ModelContext
    private let originalNote: String
    
    var hasChanges: Bool {
        noteText.trimmingCharacters(in: .whitespacesAndNewlines) != originalNote
    }
    
    var canSave: Bool {
        hasChanges
    }
    
    init(session: FocusSession, modelContext: ModelContext) {
        self.session = session
        self.modelContext = modelContext
        self.noteText = session.note
        self.originalNote = session.note
    }
    
    func saveNote() {
        let trimmedNote = noteText.trimmingCharacters(in: .whitespacesAndNewlines)
        session.note = trimmedNote
        
        do {
            try modelContext.save()
            
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.success)
        } catch {
            assertionFailure("Error saving note: \(error)")
        }
    }
    
    func discardChanges() {
        noteText = originalNote
    }
}
