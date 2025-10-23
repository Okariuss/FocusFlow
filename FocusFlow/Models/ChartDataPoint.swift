//
//  ChartDataPoint.swift
//  FocusFlow
//
//  Created by Okan Orkun on 23.10.2025.
//

import Foundation

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let label: String
    let value: Int
    let date: Date
    
    var valueInMinutes: Double {
        Double(value) / 60.0
    }
    
    var formattedValue: String {
        value.formattedDuration()
    }
}
