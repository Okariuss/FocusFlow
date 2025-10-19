//
//  FocusSession.swift
//  FocusFlow
//
//  Created by Okan Orkun on 16.10.2025.
//

import Foundation
import SwiftData

@Model
final class FocusSession {
    var id: UUID
    var startTime: Date
    var endTime: Date?
    var note: String
    var pauseCount: Int
    var totalPauseDuration: TimeInterval
    var pauseTimestamps: [Date]
    var resumeTimestamps: [Date]
    
    init(
        startTime: Date = Date(),
        endTime: Date? = nil,
        note: String = "",
        pauseCount: Int = 0,
        totalPauseDuration: TimeInterval = 0,
        pauseTimestamps: [Date] = [],
        resumeTimestamps: [Date] = []
    ) {
        self.id = UUID()
        self.startTime = startTime
        self.endTime = endTime
        self.note = note
        self.pauseCount = pauseCount
        self.totalPauseDuration = totalPauseDuration
        self.pauseTimestamps = pauseTimestamps
        self.resumeTimestamps = resumeTimestamps
    }
    
    var duration: TimeInterval {
        let end = endTime ?? Date()
        let totalTime = end.timeIntervalSince(startTime)
        
        return max(0, totalTime - totalPauseDuration)
    }
    
    var durationInMinutes: Int {
        Int(duration / 60)
    }
    
    var isActive: Bool {
        endTime == nil
    }
    
    var formattedDuration: String {
        let totalSeconds = Int(duration)
        return totalSeconds.formattedDuration()
    }
}
