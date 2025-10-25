//
//  HapticFeedbackServiceTests.swift
//  FocusFlow
//
//  Created by Okan Orkun on 24.10.2025.
//

import Testing
@testable import FocusFlow

@Suite("Haptic Feedback Service Tests")
struct HapticFeedbackServiceTests {
    
    @Test func testSuccessHaptic() {
        let service = HapticFeedbackService()
        // Just verify it doesn't crash
        service.success()
    }
    
    @Test func testLightHaptic() {
        let service = HapticFeedbackService()
        service.light()
    }
    
    @Test func testMediumHaptic() {
        let service = HapticFeedbackService()
        service.medium()
    }
}
