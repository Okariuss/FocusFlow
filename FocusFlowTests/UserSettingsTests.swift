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
    
    @Test func testSettingsInitialization() async throws {
        let settings = UserSettings()
        
        #expect(settings.lastSessionDate == nil)
        #expect(settings.darkModePreference == nil)
        
        // First launch date should be close to now (within 1 second)
        let now = Date()
        #expect(abs(settings.firstLaunchDate.timeIntervalSince(now)) < 1)
    }
    
    @Test func testFocusedTodayNoSessions() async throws {
        let settings = UserSettings()
        #expect(settings.focusedToday == false)
    }
    
    @Test func testFocusedTodayWithTodaySession() async throws {
        let settings = UserSettings(lastSessionDate: Date())
        #expect(settings.focusedToday == true)
    }
    
    @Test func testFocusedTodayWithYesterdaySession() async throws {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let settings = UserSettings(lastSessionDate: yesterday)
        #expect(settings.focusedToday == false)
    }
    
    @Test func testDarkModePreference() async throws {
        let settingsLight = UserSettings(darkModePreference: false)
        #expect(settingsLight.darkModePreference == false)
        
        let settingsDark = UserSettings(darkModePreference: true)
        #expect(settingsDark.darkModePreference == true)
        
        let settingsDefault = UserSettings()
        #expect(settingsDefault.darkModePreference == nil)
    }
}
