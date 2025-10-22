//
//  AnalyticsViewModel.swift
//  FocusFlow
//
//  Created by Okan Orkun on 22.10.2025.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable
final class AnalyticsViewModel {
    var sessions: [FocusSession] = []
    var selectedPeriod: TimePeriod = .daily
    
    private var modelContext: ModelContext
    
    enum TimePeriod: String, CaseIterable, Identifiable {
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
        
        var id: String { rawValue }
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadSessions()
    }
    
    func loadSessions() {
        sessions = fetchAllCompletedSessions()
    }
    
    var totalFocusTime: String {
        "0h 0m 0s"
    }
    
    var averageSessionLength: String {
        "0m"
    }
    
    var longestStreak: Int {
        0
    }
    
    var totalSessions: Int {
        sessions.count
    }
}

private extension AnalyticsViewModel {
    func fetchAllCompletedSessions() -> [FocusSession] {
        let descriptor = FetchDescriptor<FocusSession>(
            predicate: #Predicate { session in
                session.endTime != nil
            },
            sortBy: [SortDescriptor(\.startTime, order: .reverse)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            assertionFailure("Error loading sessions: \(error)")
            return []
        }
    }
}
