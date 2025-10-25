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
    private var persistenceService: DataPersistenceService
    
    // MARK: Computed Properties
    var isSessionActive: Bool {
        currentSession != nil
    }
    
    var formattedTime: String {
        formatTime(elapsedTime)
    }
    
    var statusText: String {
        isPaused ? "Paused" : (isSessionActive ? "Focusing..." : "Ready to focus")
    }
    
    var todaysTotalSecondsFormatted: String {
        calculateTodaysTotal().formattedDuration()
    }
    
    init(persistenceService: DataPersistenceService) {
        self.persistenceService = persistenceService
    }
    
    convenience init(modelContext: ModelContext) {
        self.init(persistenceService: SwiftDataPersistenceService(modelContext: modelContext))
    }
    
    deinit {
        stopTimer()
    }
}

// MARK: Session Management
extension TimerViewModel {
    func startSession() {
        guard currentSession == nil else { return }
        
        let newSession = FocusSession(startTime: Date())
        currentSession = newSession
        persistenceService.insert(newSession)
        
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
            try persistenceService.save()
        } catch {
            assertionFailure("❌ Failed to save session: \(error.localizedDescription)")
        }
        
        resetSession()
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
}

private extension TimerViewModel {
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateElapsedTime()
            }
        }
        
        if let timer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func updateElapsedTime() {
        guard let session = currentSession, !isPaused else { return }
        
        let totalTime = Date().timeIntervalSince(session.startTime)
        elapsedTime = totalTime - session.totalPauseDuration
    }
    
    func resetSession() {
        currentSession = nil
        elapsedTime = 0
        isPaused = false
        pauseStartTime = nil
    }
    
    func calculateTodaysTotal() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) else { return 0 }
        
        let descriptor = FetchDescriptor<FocusSession>(
            predicate: #Predicate { session in
                session.startTime >= today && session.startTime < tomorrow
            },
            sortBy: [SortDescriptor(\.startTime)]
        )
        
        guard let sessions = try? persistenceService.fetch(descriptor) else { return 0 }
        
        var totalSeconds: TimeInterval = 0
        
        for session in sessions where session.endTime != nil {
            totalSeconds += session.duration
        }
        
        if currentSession != nil {
            totalSeconds += elapsedTime
        }
        
        return Int(totalSeconds)
    }
    
    func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
