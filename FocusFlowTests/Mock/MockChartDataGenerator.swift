//
//  MockChartDataGenerator.swift
//  FocusFlow
//
//  Created by Okan Orkun on 24.10.2025.
//

@testable import FocusFlow

final class MockChartDataGenerator {
    var mockDataPoints: [ChartDataPoint] = []
    var generateCallCount = 0
    
    func generateDailyData(sessions: [FocusSession], days: Int) -> [ChartDataPoint] {
        generateCallCount += 1
        return mockDataPoints
    }
    
    func generateWeeklyData(sessions: [FocusSession], weeks: Int) -> [ChartDataPoint] {
        generateCallCount += 1
        return mockDataPoints
    }
    
    func generateMonthlyData(sessions: [FocusSession], months: Int) -> [ChartDataPoint] {
        generateCallCount += 1
        return mockDataPoints
    }
    
    func reset() {
        mockDataPoints = []
        generateCallCount = 0
    }
}
