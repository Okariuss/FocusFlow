//
//  StreakCalculator.swift
//  FocusFlow
//
//  Created by Okan Orkun on 24.10.2025.
//

import Foundation

protocol StreakCalculating {
    func calculateLongestStreak(from sessions: [FocusSession]) -> Int
}

final class StreakCalculator: StreakCalculating {
    func calculateLongestStreak(from sessions: [FocusSession]) -> Int {
        guard !sessions.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let sessionDates = sessions
            .map { calendar.startOfDay(for: $0.startTime) }
            .uniqued()
            .sorted(by: >)
        
        guard !sessionDates.isEmpty else { return 0 }
        
        var maxStreak = 1
        var currentStreak = 1
        
        for i in 0..<(sessionDates.count - 1) {
            if let dayDifference = calendar.dateComponents([.day], from: sessionDates[i+1], to: sessionDates[i]).day,
               dayDifference == 1 {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }
        
        return maxStreak
    }
}
