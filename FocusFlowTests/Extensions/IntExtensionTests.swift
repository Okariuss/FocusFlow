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

    @Test("formattedDuration handles hours, minutes, seconds")
    func testFormattedDuration() async throws {
        #expect(3661.formattedDuration() == "1h 1m 1s")
    }
    
    @Test("formattedDuration for minutes only")
    func testFormattedDurationMinutes() async throws {
        #expect(180.formattedDuration() == "3m")
    }
    
    @Test("formattedDuration for seconds only and negatives")
    func testFormattedDurationSecondsAndNegative() async throws {
        #expect(45.formattedDuration() == "45s")
        #expect((-100).formattedDuration() == "0s")
    }
}
