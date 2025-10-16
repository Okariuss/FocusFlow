//
//  UserSettings.swift
//  FocusFlow
//
//  Created by Okan Orkun on 16.10.2025.
//

import Foundation
import SwiftData

@Model
final class UserSettings {
    var id: UUID
    var firstLaunchDate: Date
    var lastSessionDate: Date?
    var darkModePreference: Bool?
    
    init(
        firstLaunchDate: Date = Date(),
        lastSessionDate: Date? = nil,
        darkModePreference: Bool? = nil
    ) {
        self.id = UUID()
        self.firstLaunchDate = firstLaunchDate
        self.lastSessionDate = lastSessionDate
        self.darkModePreference = darkModePreference
    }
    
    var focusedToday: Bool {
        guard let lastSessionDate else { return false }
        return Calendar.current.isDateInToday(lastSessionDate)
    }
    
    func calculateStreak(sessions: [FocusSession]) -> Int {
        // TODO: This will be implemented in a later build when we have session data
        // For now, return 0
        return 0
    }
}
