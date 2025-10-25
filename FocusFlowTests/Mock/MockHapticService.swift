//
//  MockHapticService.swift
//  FocusFlow
//
//  Created by Okan Orkun on 24.10.2025.
//

import Foundation
@testable import FocusFlow

final class MockHapticService: HapticFeedbackProviding {
    var successCallCount = 0
    var lightCallCount = 0
    var mediumCallCount = 0
    
    func success() {
        successCallCount += 1
    }
    
    func light() {
        lightCallCount += 1
    }
    
    func medium() {
        mediumCallCount += 1
    }
    
    func reset() {
        successCallCount = 0
        lightCallCount = 0
        mediumCallCount = 0
    }
}
