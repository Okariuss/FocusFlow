//
//  SessionStatisticsCalculator.swift
//  FocusFlow
//
//  Created by Okan Orkun on 24.10.2025.
//

final class SessionStatisticsCalculator {
    func calculateTotalFocusTime(from sessions: [FocusSession]) -> Int {
        sessions.reduce(0) { $0 + Int($1.duration) }
    }
    
    func calculateAverageSessionLength(from sessions: [FocusSession]) -> Int {
        guard !sessions.isEmpty else { return 0 }
        let total = calculateTotalFocusTime(from: sessions)
        return total / sessions.count
    }
}
