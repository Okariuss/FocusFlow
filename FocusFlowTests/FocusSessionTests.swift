//
//  FocusSessionTests.swift
//  FocusFlowTests
//
//  Created by Okan Orkun on 16.10.2025.
//

import Testing
import Foundation
@testable import FocusFlow

@Suite("FocusSession Model Tests")
struct FocusSessionTests {

    @Test func testSessionInitialization() {
        let session = FocusSession()
        
        #expect(session.note == "")
        #expect(session.pauseCount == 0)
        #expect(session.totalPauseDuration == 0)
        #expect(session.pauseTimestamps.isEmpty)
        #expect(session.resumeTimestamps.isEmpty)
        #expect(session.isActive == true)
        #expect(session.endTime == nil)
    }
    
    @Test func testDurationCalculation() {
        let start = Date()
        let end = start.addingTimeInterval(3600) // 1 hour
        
        let session = FocusSession(
            startTime: start,
            endTime: end
        )
        
        #expect(session.duration == 3600)
        #expect(session.durationInMinutes == 60)
    }
    
    @Test func testDurationWithPause() {
        let start = Date()
        let end = start.addingTimeInterval(3600) // 1 hour total
        
        let session = FocusSession(
            startTime: start,
            endTime: end,
            pauseCount: 1,
            totalPauseDuration: 600 // 10 minutes paused
        )
        
        // 60 - 10 = 50 minutes
        #expect(session.duration == 3000)
        #expect(session.durationInMinutes == 50)
    }
    
    @Test func testActiveSessionDuration() {
        let start = Date().addingTimeInterval(-1800) // 30 min ago
        let session = FocusSession(startTime: start)
        
        let expectedDuration: TimeInterval = 1800
        #expect(abs(session.duration - expectedDuration) < 1)
    }
    
    @Test func testFormattedDuration() {
        let start = Date()
        
        let session1 = FocusSession(
            startTime: start,
            endTime: start.addingTimeInterval(2400) // 40 min
        )
        #expect(session1.formattedDuration == "40m")
        
        let session2 = FocusSession(
            startTime: start,
            endTime: start.addingTimeInterval(5400) // 1h 30m
        )
        #expect(session2.formattedDuration == "1h 30m")
        
        let session3 = FocusSession(
            startTime: start,
            endTime: start.addingTimeInterval(45) // 45s
        )
        #expect(session3.formattedDuration == "45s")
    }
    
    @Test func testIsActiveProperty() {
        let activeSession = FocusSession(endTime: nil)
        #expect(activeSession.isActive == true)
        
        let completedSession = FocusSession(endTime: Date())
        #expect(completedSession.isActive == false)
    }
}
