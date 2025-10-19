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

    @Test func testFormatDateToday() {
        let today = Date()
        let formatted = Date.formatDate(today)
        #expect(formatted == "Today")
    }
    
    @Test func testFormatDateYesterday() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let formatted = Date.formatDate(yesterday)
        #expect(formatted == "Yesterday")
    }
    
    @Test func testFormatDateOlder() {
        let oldDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let formatted = Date.formatDate(oldDate)
        
        #expect(formatted != "Today")
        #expect(formatted != "Yesterday")
        #expect(!formatted.isEmpty)
    }
    
    @Test func testFormatTime() {
        let date = Date()
        let formatted = Date.formatTime(date)
        
        #expect(!formatted.isEmpty)
        #expect(formatted.count < 20)
    }
    
    @Test func testFormatDateWithStyle() {
        let date = Date()
        let formatted = date.formatDateWithStyle(dateStyle: .long)
        
        #expect(!formatted.isEmpty)
    }
}
