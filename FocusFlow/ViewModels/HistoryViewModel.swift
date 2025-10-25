//
//  HistoryViewModel.swift
//  FocusFlow
//
//  Created by Okan Orkun on 18.10.2025.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable
final class HistoryViewModel: SessionManaging {
    var sessions: [FocusSession] = []
    var sessionToDelete: FocusSession?
    var showDeleteConfirmation = false
    
    private let persistenceService: DataPersistenceService
    private let hapticService: HapticFeedbackProviding
    
    init(
        persistenceService: DataPersistenceService,
        hapticService: HapticFeedbackProviding = HapticFeedbackService()
    ) {
        self.persistenceService = persistenceService
        self.hapticService = hapticService
        loadSessions()
    }
    
    convenience init(modelContext: ModelContext) {
        self.init(persistenceService: SwiftDataPersistenceService(modelContext: modelContext))
    }
    
    // MARK: Session Management
    func loadSessions() {
        sessions = fetchCompletedSessions()
        
    }
    
    func deleteSession(_ session: FocusSession) {
        persistenceService.delete(session)
        
        do {
            try persistenceService.save()
            loadSessions()
        } catch {
            assertionFailure("Error deleting session: \(error)")
        }
    }
    
    // MARK: Delete Confirmation
    func requestDeleteSession(_ session: FocusSession) {
        sessionToDelete = session
        showDeleteConfirmation = true
    }
    
    func confirmDelete() {
        guard let session = sessionToDelete else { return }
        
        withAnimation {
            deleteSession(session)
        }
        
        hapticService.success()
        resetDeleteState()
    }
    
    func cancelDelete() {
        hapticService.light()
        
        withAnimation(.none) {
            resetDeleteState()
        }
    }
    
    // MARK: Data Grouping
    func sessionsByDate() -> [(String, [FocusSession])] {
        groupSessionsByDate(sessions)

    }
}


private extension HistoryViewModel {
    func fetchCompletedSessions() -> [FocusSession] {
        let descriptor = FetchDescriptor<FocusSession>(
            predicate: #Predicate { session in
                session.endTime != nil
            },
            sortBy: [SortDescriptor(\.startTime, order: .reverse)]
        )
        
        do {
            return try persistenceService.fetch(descriptor)
        } catch {
            assertionFailure("Error loading sessions: \(error)")
            return []
        }
    }
    
    func groupSessionsByDate(_ sessions: [FocusSession]) -> [(String, [FocusSession])] {
        var grouped: [String: [FocusSession]] = [:]
        
        for session in sessions {
            let dateKey = Date.formatDate(session.startTime)
            grouped[dateKey, default: []].append(session)
        }
        
        return grouped.sorted(by: sortDateSections)
    }
    
    func sortDateSections(
        _ first: (key: String, value: [FocusSession]),
        _ second: (key: String, value: [FocusSession])
    ) -> Bool {
        if first.key == "Today" { return true }
        if second.key == "Today" { return false }
        if first.key == "Yesterday" { return true }
        if second.key == "Yesterday" { return false }
        return first.key > second.key
    }
    
    func resetDeleteState() {
        sessionToDelete = nil
        showDeleteConfirmation = false
    }
}
