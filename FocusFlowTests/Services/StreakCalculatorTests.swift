//
//  StreakCalculatorTests.swift
//  FocusFlow
//
//  Created by Okan Orkun on 24.10.2025.
//

import Testing
import Foundation
@testable import FocusFlow

@Suite("Streak Calculator Tests")
struct StreakCalculatorTests {
    
    @Test func testEmptySessions() {
        let calculator = StreakCalculator()
        let streak = calculator.calculateLongestStreak(from: [])
        #expect(streak == 0)
    }
    
    @Test func testSingleSession() {
        let calculator = StreakCalculator()
        let session = FocusSession(startTime: Date(), endTime: Date())
        let streak = calculator.calculateLongestStreak(from: [session])
        #expect(streak == 1)
    }
    
    @Test func testConsecutiveDays() {
        let calculator = StreakCalculator()
        let calendar = Calendar.current
        let today = Date()
        
        let sessions = (0..<5).map { offset in
            let date = calendar.date(byAdding: .day, value: -offset, to: today)!
            return FocusSession(startTime: date, endTime: date.addingTimeInterval(1800))
        }
        
        let streak = calculator.calculateLongestStreak(from: sessions)
        #expect(streak == 5)
    }
    
    @Test func testStreakWithGap() {
        let calculator = StreakCalculator()
        let calendar = Calendar.current
        let today = Date()
        
        var sessions: [FocusSession] = []
        
        // 3 consecutive days
        for i in 0..<3 {
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            sessions.append(FocusSession(startTime: date, endTime: date.addingTimeInterval(1800)))
        }
        
        // Gap of 2 days
        
        // 2 more consecutive days
        for i in 5..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            sessions.append(FocusSession(startTime: date, endTime: date.addingTimeInterval(1800)))
        }
        
        let streak = calculator.calculateLongestStreak(from: sessions)
        #expect(streak == 3)
    }
}
