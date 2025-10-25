//
//  ChartDataGeneratorTests.swift
//  FocusFlow
//
//  Created by Okan Orkun on 24.10.2025.
//

import Testing
import Foundation
@testable import FocusFlow

@Suite("Chart Data Generator Tests")
struct ChartDataGeneratorTests {
    
    @Test func testGenerateDailyData() {
        let generator = ChartDataGenerator()
        let today = Date()
        
        let session = FocusSession(startTime: today, endTime: today.addingTimeInterval(1800))
        let dataPoints = generator.generateDailyData(sessions: [session], days: 7)
        
        #expect(dataPoints.count == 7)
        #expect(dataPoints.last?.value == 1800)
    }
    
    @Test func testGenerateWeeklyData() {
        let generator = ChartDataGenerator()
        let dataPoints = generator.generateWeeklyData(sessions: [], weeks: 4)
        
        #expect(dataPoints.count == 4)
    }
    
    @Test func testGenerateMonthlyData() {
        let generator = ChartDataGenerator()
        let dataPoints = generator.generateMonthlyData(sessions: [], months: 6)
        
        #expect(dataPoints.count == 6)
    }
}
