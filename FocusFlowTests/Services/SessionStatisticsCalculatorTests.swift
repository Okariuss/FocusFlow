//
//  SessionStatisticsCalculatorTests.swift
//  FocusFlow
//
//  Created by Okan Orkun on 24.10.2025.
//

import Testing
import Foundation
@testable import FocusFlow

@Suite("Session Statistics Calculator Tests")
struct SessionStatisticsCalculatorTests {
    
    @Test func testTotalFocusTimeEmpty() {
        let calculator = SessionStatisticsCalculator()
        let total = calculator.calculateTotalFocusTime(from: [])
        #expect(total == 0)
    }
    
    @Test func testTotalFocusTimeMultipleSessions() {
        let calculator = SessionStatisticsCalculator()
        
        let session1 = FocusSession(
            startTime: Date(),
            endTime: Date().addingTimeInterval(1800) // 30 min
        )
        let session2 = FocusSession(
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600) // 60 min
        )
        
        let total = calculator.calculateTotalFocusTime(from: [session1, session2])
        #expect(total == 5400) // 90 minutes in seconds
    }
    
    @Test func testAverageSessionLengthEmpty() {
        let calculator = SessionStatisticsCalculator()
        let average = calculator.calculateAverageSessionLength(from: [])
        #expect(average == 0)
    }
    
    @Test func testAverageSessionLength() {
        let calculator = SessionStatisticsCalculator()
        
        let sessions = (0..<3).map { _ in
            FocusSession(startTime: Date(), endTime: Date().addingTimeInterval(1800))
        }
        
        let average = calculator.calculateAverageSessionLength(from: sessions)
        #expect(average == 1800) // 30 minutes
    }
}
