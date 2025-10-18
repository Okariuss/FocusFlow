//
//  TimerViewModel.swift
//  FocusFlow
//
//  Created by Okan Orkun on 17.10.2025.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
final class TimerViewModel {
    var currentSession: FocusSession?
    var elapsedTime: TimeInterval = 0
    var isPaused: Bool = false
    
    private var pauseStartTime: Date?
    private var timer: Timer?
    private var modelContext: ModelContext
    
    var isSessionActive: Bool {
        currentSession != nil
    }
    
    var formattedTime: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = (Int(elapsedTime) % 3600) / 60
        let seconds = Int(elapsedTime) % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    var statusText: String {
        isPaused ? "Paused" : (isSessionActive ? "Focusing..." : "Ready to focus")
    }
    
    var todaysTotalMinutes: Int {
        calculateTodaysTotal()
    }
    
    var todaysTotalFormatted: String {
        let minutes = todaysTotalMinutes
        
        if minutes == 0 {
            return "0m"
        } else if minutes < 60 {
            return "\(minutes)m"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            if remainingMinutes == 0 {
                return "\(hours)h"
            } else {
                return "\(hours)h \(remainingMinutes)m"
            }
        }
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    deinit {
        stopTimer()
    }
    
    func startSession() {
        guard currentSession == nil else { return }
        
        let newSession = FocusSession(startTime: Date())
        currentSession = newSession
        modelContext.insert(newSession)
        
        elapsedTime = 0
        startTimer()
    }
    
    func stopSession() {
        guard let session = currentSession else { return }
        
        if isPaused {
            resumeSession()
        }
        
        stopTimer()
        session.endTime = Date()
        
        do {
            try modelContext.save()
        } catch {
            assertionFailure("❌ Failed to save session: \(error.localizedDescription)")
        }
        
        currentSession = nil
        elapsedTime = 0
        isPaused = false
        pauseStartTime = nil
    }
    
    func pauseSession() {
        guard let session = currentSession, !isPaused else { return }
        
        stopTimer()
        
        isPaused = true
        pauseStartTime = Date()
        
        session.pauseTimestamps.append(Date())
        session.pauseCount += 1
    }
    
    func resumeSession() {
        guard let session = currentSession, isPaused else { return }
        
        if let pauseStart = pauseStartTime {
            let pauseDuration = Date().timeIntervalSince(pauseStart)
            session.totalPauseDuration += pauseDuration
        }
        
        session.resumeTimestamps.append(Date())
        
        isPaused = false
        pauseStartTime = nil
        
        startTimer()
    }
    
    func refreshTodaysTotal() {
        _ = todaysTotalMinutes
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateElapsedTime()
        }
        
        if let timer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateElapsedTime() {
        guard let session = currentSession else { return }
        
        if isPaused {
            return
        }
        
        let totalTime = Date().timeIntervalSince(session.startTime)
        
        elapsedTime = totalTime - session.totalPauseDuration
    }
    
    private func calculateTodaysTotal() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        var descriptor = FetchDescriptor<FocusSession>(
            predicate: #Predicate { session in
                session.startTime >= today && session.startTime < tomorrow
            }
        )
        
        descriptor.sortBy = [SortDescriptor(\.startTime)]
        
        guard let sessions = try? modelContext.fetch(descriptor) else {
            return 0
        }
        
        var totalSeconds: TimeInterval = 0
        
        for session in sessions {
            if session.endTime != nil {
                totalSeconds += session.duration
            }
        }
        
        if let currentSession {
            totalSeconds += elapsedTime
        }
        
        return Int(totalSeconds / 60)
    }
}
