//
//  MockStreakCalculator.swift
//  FocusFlow
//
//  Created by Okan Orkun on 24.10.2025.
//

import Foundation
@testable import FocusFlow

final class MockStreakCalculator: StreakCalculating {
    var mockStreak = 0
    var calculateCallCount = 0
    
    func calculateLongestStreak(from sessions: [FocusSession]) -> Int {
        calculateCallCount += 1
        return mockStreak
    }
    
    func reset() {
        mockStreak = 0
        calculateCallCount = 0
    }
}
