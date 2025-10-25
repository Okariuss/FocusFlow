//
//  Int+Extensions.swift
//  FocusFlow
//
//  Created by Okan Orkun on 18.10.2025.
//

import Foundation

extension Int {
    func formattedDuration() -> String {
        let totalSeconds = Swift.max(0, self)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        var parts: [String] = []
        
        if hours > 0 {
            parts.append("\(hours)h")
        }
        if minutes > 0 {
            parts.append("\(minutes)m")
        }
        if seconds > 0 || parts.isEmpty {
            parts.append("\(seconds)s")
        }
        
        return parts.joined(separator: " ")
    }
}
