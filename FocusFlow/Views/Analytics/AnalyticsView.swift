//
//  AnalyticsView.swift
//  FocusFlow
//
//  Created by Okan Orkun on 22.10.2025.
//

import SwiftUI
import SwiftData
import Charts

struct AnalyticsView: View {
    
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: AnalyticsViewModel?
    @State private var selectedDataPoint: ChartDataPoint?
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Analytics")
                .onAppear(perform: setupViewModel)
        }
    }
}

private extension AnalyticsView {
    
    var content: some View {
        ScrollView {
            VStack(spacing: 24) {
                periodPicker
                
                if viewModel?.sessions.isEmpty == true {
                    emptyState
                        .frame(minHeight: 400)
                } else {
                    statisticsCards
                    chartSection
                }
            }
            .padding()
        }
    }
    
    var periodPicker: some View {
        Picker("Period", selection: Binding(
            get: { viewModel?.selectedPeriod ?? .daily },
            set: { viewModel?.selectedPeriod = $0 }
        )) {
            ForEach(AnalyticsViewModel.TimePeriod.allCases) { period in
                Text(period.rawValue).tag(period)
            }
        }
        .pickerStyle(.segmented)
    }
    
    var emptyState: some View {
        ContentUnavailableView("No Data Yet", systemImage: "chart.bar.xaxis", description: Text("Complete some focus sessions to see your analytics"))
            .padding(.vertical, 60)
    }
    
    var statisticsCards: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                statisticCard(
                    icon: "clock.fill",
                    title: "Total Time",
                    value: viewModel?.totalFocusTime ?? "0h 0m 0s",
                    color: .blue
                )
                
                statisticCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Average",
                    value: viewModel?.averageSessionLength ?? "0h 0m 0s",
                    color: .green
                )
            }
            
            HStack(spacing: 12) {
                statisticCard(
                    icon: "flame.fill",
                    title: "Streak",
                    value: "\(viewModel?.longestStreak ?? 0) days",
                    color: .orange
                )
                
                statisticCard(
                    icon: "number",
                    title: "Sessions",
                    value: "\(viewModel?.totalSessions ?? 0)",
                    color: .purple
                )
            }
        }
    }
    
    func statisticCard(icon: String, title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    var chartSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Focus Time")
                    .font(.headline)
                Spacer()
            }
            chartContent
                .frame(height: 200)
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    var chartContent: some View {
        VStack {
            if let dataPoints = viewModel?.chartDataPoints, !dataPoints.isEmpty {
                focusTimeChart(dataPoints: dataPoints)
            } else {
                emptyChartState
            }
        }
        .animation(.easeInOut, value: viewModel?.selectedPeriod)
    }
    
    func focusTimeChart(dataPoints: [ChartDataPoint]) -> some View {
        Chart(dataPoints) { point in
            BarMark(
                x: .value("Period", point.label),
                y: .value("Duration", point.valueInMinutes)
            )
            .foregroundStyle(
                point.valueInMinutes > 0 ? Color.blue.gradient : Color.gray.opacity(0.3).gradient
            )
            .cornerRadius(6)
            .annotation(position: .top) {
                if point.valueInMinutes > 0 {
                    Text(point.formattedValue)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                    .foregroundStyle(Color.gray.opacity(0.2))
                AxisValueLabel {
                    if let minutes = value.as(Double.self) {
                        Text("\(Int(minutes))m")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let label = value.as(String.self) {
                        Text(label)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .frame(height: 200)
    }
    
    var emptyChartState: some View {
        ContentUnavailableView("No data for this period", systemImage: "chart.bar")
            .frame(maxHeight: .infinity)
    }
}

private extension AnalyticsView {
    func setupViewModel() {
        if viewModel == nil {
            viewModel = AnalyticsViewModel(modelContext: modelContext)
        } else {
            viewModel?.loadSessions()
        }
    }
}

// MARK: - Preview
#Preview("With Data") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: FocusSession.self, UserSettings.self,
        configurations: config
    )
    let context = ModelContext(container)
    
    // Create sample sessions
    for i in 0..<10 {
        let session = FocusSession(
            startTime: Date().addingTimeInterval(TimeInterval(-i * 86400)),
            endTime: Date().addingTimeInterval(TimeInterval(-i * 86400 + 1800))
        )
        context.insert(session)
    }
    
    return AnalyticsView()
        .modelContainer(container)
}

#Preview("Empty") {
    AnalyticsView()
        .modelContainer(for: [FocusSession.self, UserSettings.self])
}
