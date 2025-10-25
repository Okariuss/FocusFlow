//
//  ChartDataPointTests.swift
//  FocusFlow
//
//  Created by Okan Orkun on 23.10.2025.
//

import Testing
import Foundation
@testable import FocusFlow

@Suite("ChartDataPoint Model Tests")
struct ChartDataPointTests {

    @Test("valueInMinutes computed correctly")
    func testValueInMinutes() async throws {
        let date = Date()
        let data = ChartDataPoint(label: "Test", value: 120, date: date)
        #expect(data.valueInMinutes == 2.0)
    }
    
    @Test("formattedValue uses Int extension")
    func testFormattedValue() async throws {
        let date = Date()
        let data = ChartDataPoint(label: "Test", value: 61, date: date)
        #expect(data.formattedValue == "1m 1s")
    }
}
