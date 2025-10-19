//
//  IntExtensionTests.swift
//  FocusFlowTests
//
//  Created by Okan Orkun on 19.10.2025.
//

import Testing
import Foundation
@testable import FocusFlow

@Suite("Int Extension Tests")
struct IntExtensionTests {

    @Test func testFormattedDurationSeconds() {
        let seconds = 45
        #expect(seconds.formattedDuration() == "45s")
    }
    
    @Test func testFormattedDurationMinutes() {
        let seconds = 90 // 1m 30s
        #expect(seconds.formattedDuration() == "1m 30s")
    }
    
    @Test func testFormattedDurationHours() {
        let seconds = 3665 // 1h 1m 5s
        #expect(seconds.formattedDuration() == "1h 1m 5s")
    }
    
    @Test func testFormattedDurationExactMinute() {
        let seconds = 60
        #expect(seconds.formattedDuration() == "1m")
    }
    
    @Test func testFormattedDurationExactHour() {
        let seconds = 3600
        #expect(seconds.formattedDuration() == "1h")
    }
    
    @Test func testFormattedDurationZero() {
        let seconds = 0
        #expect(seconds.formattedDuration() == "0s")
    }
    
    @Test func testFormattedDurationLarge() {
        let seconds = 7265 // 2h 1m 5s
        #expect(seconds.formattedDuration() == "2h 1m 5s")
    }
}
