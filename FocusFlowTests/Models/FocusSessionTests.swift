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

    @Test("duration calculates correctly with endTime and pauses")
    func testDurationCalculation() async throws {
        let start = Date()
        let end = start.addingTimeInterval(3600)
        let session = FocusSession(startTime: start, endTime: end, totalPauseDuration: 600)
        #expect(Int(session.duration) == 3000)
    }
    
    @Test("formattedDuration displays correctly")
    func testFormattedDuration() async throws {
        let start = Date()
        let end = start.addingTimeInterval(3661)
        let session = FocusSession(startTime: start, endTime: end)
        #expect(session.formattedDuration == "1h 1m 1s")
    }
}
