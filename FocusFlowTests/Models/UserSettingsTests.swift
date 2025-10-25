//
//  UserSettingsTests.swift
//  FocusFlow
//
//  Created by Okan Orkun on 16.10.2025.
//

import Testing
import Foundation
@testable import FocusFlow

@Suite("UserSettings Model Tests")
struct UserSettingsTests {
    
    @Test("initializes with default values")
    func testInitialization() async throws {
        let settings = UserSettings()
        #expect(settings.firstLaunchDate.timeIntervalSince1970 > 0)
        #expect(settings.darkModePreference == nil)
    }
    
    @Test("initializes with custom values")
    func testCustomInitialization() async throws {
        let now = Date()
        let settings = UserSettings(firstLaunchDate: now, lastSessionDate: now, darkModePreference: true)
        #expect(settings.firstLaunchDate == now)
        #expect(settings.lastSessionDate == now)
        #expect(settings.darkModePreference == true)
    }
}
