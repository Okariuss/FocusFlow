//
//  AnalyticsViewModelTests.swift
//  FocusFlow
//
//  Created by Okan Orkun on 22.10.2025.
//

import Foundation
import SwiftData
import Testing
@testable import FocusFlow

@Suite("Analytics ViewModel Tests")
@MainActor
struct AnalyticsViewModelTests {
    
    @Test func testInitialization() {
        let mockService = MockPersistenceService()
        let viewModel = AnalyticsViewModel(persistenceService: mockService)
        
        #expect(viewModel.sessions.isEmpty)
        #expect(viewModel.selectedPeriod == .daily)
    }
    
    @Test func testTotalFocusTime() {
        let mockService = MockPersistenceService()
        let session = FocusSession(
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600)
        )
        mockService.storage.append(session)
        
        let viewModel = AnalyticsViewModel(persistenceService: mockService)
        
        #expect(viewModel.totalFocusTime.contains("1h"))
    }
    
    @Test func testAverageSessionLength() {
        let mockService = MockPersistenceService()
        let sessions = (0..<3).map { _ in
            FocusSession(startTime: Date(), endTime: Date().addingTimeInterval(1800))
        }
        mockService.storage.append(contentsOf: sessions)
        
        let viewModel = AnalyticsViewModel(persistenceService: mockService)
        
        #expect(viewModel.averageSessionLength.contains("30m"))
    }
    
    @Test func testPeriodSelection() {
        let mockService = MockPersistenceService()
        let viewModel = AnalyticsViewModel(persistenceService: mockService)
        
        viewModel.selectedPeriod = .weekly
        #expect(viewModel.selectedPeriod == .weekly)
        
        viewModel.selectedPeriod = .monthly
        #expect(viewModel.selectedPeriod == .monthly)
    }
}
