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
        isSessionActive ? "Focusing..." : "Ready to focus"
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
        
        stopTimer()
        session.endTime = Date()
        
        do {
            try modelContext.save()
        } catch {
            assertionFailure("❌ Failed to save session: \(error.localizedDescription)")
        }
        
        currentSession = nil
        elapsedTime = 0
    }
    
    private func startTimer() {
        stopTimer()
        
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
        elapsedTime = Date().timeIntervalSince(session.startTime)
    }
}
