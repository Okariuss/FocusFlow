//
//  FocusSessionTests.swift
//  FocusFlowTests
//
//  Created by Okan Orkun on 16.10.2025.
//

import Testing
import Foundation
@testable import FocusFlow

struct FocusSessionTests {

    @Test func testSessionInitialization() async throws {
        let session = FocusSession()
        
        #expect(session.note == "")
        #expect(session.pauseCount == 0)
        #expect(session.totalPauseDuration == 0)
        #expect(session.pauseTimestamps.isEmpty)
        #expect(session.resumeTimestamps.isEmpty)
        #expect(session.isActive == true)
        #expect(session.endTime == nil)
    }
    
    @Test func testDurationCalculation() async throws {
        let start = Date()
        let end = start.addingTimeInterval(3600)
        
        let session = FocusSession(
            startTime: start,
            endTime: end
        )
        
        #expect(session.duration == 3600)
        #expect(session.durationInMinutes == 60)
    }
    
    @Test func testDurationWithPause() async throws {
        let start = Date()
        let end = start.addingTimeInterval(3600)
        
        let session = FocusSession(
            startTime: start,
            endTime: end,
            pauseCount: 1,
            totalPauseDuration: 600
        )
        
        // Should be 50 minutes of actual focus (60 - 10)
        #expect(session.duration == 3000) // 3000 seconds = 50 minutes
        #expect(session.durationInMinutes == 50)
    }

    @Test func testActiveSessionDuration() async throws {
        let start = Date().addingTimeInterval(-1800) // Started 30 minutes ago
        let session = FocusSession(startTime: start)
        
        // Duration should be approximately 30 minutes (allow 1 second tolerance)
        let expectedDuration: TimeInterval = 1800
        #expect(abs(session.duration - expectedDuration) < 1)
    }
    
    @Test func testFormattedDuration() async throws {
        let start = Date()
        
        // Test 1: Less than 1 hour
        let session1 = FocusSession(
            startTime: start,
            endTime: start.addingTimeInterval(2400) // 40 minutes
        )
        #expect(session1.formattedDuration == "40m")
        
        // Test 2: More than 1 hour
        let session2 = FocusSession(
            startTime: start,
            endTime: start.addingTimeInterval(5400) // 1 hour 30 minutes
        )
        #expect(session2.formattedDuration == "1h 30m")
        
        // Test 3: Exactly 2 hours
        let session3 = FocusSession(
            startTime: start,
            endTime: start.addingTimeInterval(7200) // 2 hours
        )
        #expect(session3.formattedDuration == "2h 0m")
    }
    
    @Test func testIsActiveProperty() async throws {
        let activeSession = FocusSession(endTime: nil)
        #expect(activeSession.isActive == true)
        
        let completedSession = FocusSession(endTime: Date())
        #expect(completedSession.isActive == false)
    }
}
