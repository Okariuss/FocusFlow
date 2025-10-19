//
//  HistoryViewModel.swift
//  FocusFlow
//
//  Created by Okan Orkun on 18.10.2025.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
final class HistoryViewModel {
    var sessions: [FocusSession] = []
    
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadSessions()
    }
    
    func loadSessions() {
        var descriptor = FetchDescriptor<FocusSession>(
            predicate: #Predicate { session in
                session.endTime != nil
            }
        )
        
        descriptor.sortBy = [SortDescriptor(\.startTime, order: .reverse)]
        
        do {
            sessions = try modelContext.fetch(descriptor)
        } catch {
            assertionFailure("Error loading sessions: \(error)")
            sessions = []
        }
    }
    
    func deleteSession(_ session: FocusSession) {
        modelContext.delete(session)
        
        do {
            try modelContext.save()
            loadSessions()
        } catch {
            assertionFailure("Error deleting session: \(error)")
        }
    }
    
    func sessionsByDate() -> [(String, [FocusSession])] {
        var grouped: [String: [FocusSession]] = [:]
        
        for session in sessions {
            let dateKey = Date.formatDate(session.startTime)
            if grouped[dateKey] == nil {
                grouped[dateKey] = []
            }
            grouped[dateKey]?.append(session)
        }
        
        let sorted = grouped.sorted { first, second in
            if first.key == "Today" { return true }
            if second.key == "Today" { return false }
            if first.key == "Yesterday" { return true }
            if second.key == "Yesterday" { return false }
            return first.key > second.key
        }
        return sorted
    }
}
