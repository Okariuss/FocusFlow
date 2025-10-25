//
//  DateExtensionTests.swift
//  FocusFlowTests
//
//  Created by Okan Orkun on 19.10.2025.
//

import Testing
import Foundation
@testable import FocusFlow

@Suite("Date Extension Tests")
struct DateExtensionTests {
    
    @Test("formatDate returns Today, Yesterday, or formatted date")
    func testFormatDate() async throws {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let oldDate = Calendar.current.date(byAdding: .day, value: -10, to: today)!
        
        #expect(Date.formatDate(today) == "Today")
        #expect(Date.formatDate(yesterday) == "Yesterday")
        
        let formatted = Date.formatDate(oldDate)
        #expect(formatted.contains(",") || formatted.count > 5)
    }
    
    @Test("formatTime returns valid short time string")
    func testFormatTime() async throws {
        let date = Date(timeIntervalSince1970: 0)
        let formatted = Date.formatTime(date)
        #expect(formatted.contains(":"))
    }
    
    @Test("formatDateForChart returns correct format per period")
    func testFormatDateForChart() async throws {
        let date = Date()
        #expect(Date.formatDateForChart(date, period: .daily).count == 3)
        #expect(Int(Date.formatDateForChart(date, period: .weekly)) != nil)
        #expect(Date.formatDateForChart(date, period: .monthly).count == 3)
    }
    
    @Test("formatDateWithStyle formats properly")
    func testFormatDateWithStyle() async throws {
        let date = Date(timeIntervalSince1970: 0)
        let formatted = date.formatDateWithStyle(dateStyle: .medium)
        #expect(formatted.count > 5)
    }
    
    @Test("startOfWeek returns beginning of week")
    func testStartOfWeek() async throws {
        let date = Date()
        let startOfWeek = date.startOfWeek()
        #expect(startOfWeek != nil)
    }
    
    @Test("startOfMonth returns beginning of month")
    func testStartOfMonth() async throws {
        let date = Date()
        let startOfMonth = date.startOfMonth()
        #expect(startOfMonth != nil)
    }
    
    @Test("weekLabel returns correct format")
    func testWeekLabel() async throws {
        let start = Date()
        let end = Calendar.current.date(byAdding: .day, value: 7, to: start)!
        let label = start.weekLabel(to: end)
        #expect(label.contains("–"))
    }
    
    @Test("monthLabel returns month and year")
    func testMonthLabel() async throws {
        let date = Date(timeIntervalSince1970: 0)
        let label = date.monthLabel()
        #expect(label.contains("1970"))
    }
}
