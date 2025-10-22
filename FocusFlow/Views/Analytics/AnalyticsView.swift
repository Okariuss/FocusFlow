//
//  AnalyticsView.swift
//  FocusFlow
//
//  Created by Okan Orkun on 22.10.2025.
//

import SwiftUI
import SwiftData

struct AnalyticsView: View {
    
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: AnalyticsViewModel?
    
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
                } else {
                    statisticsCards
                    chartPlaceholder
                }
            }
            .padding()
        }
        .refreshable {
            viewModel?.loadSessions()
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
                    value: viewModel?.totalFocusTime ?? "0h 0m",
                    color: .blue
                )
                
                statisticCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Average",
                    value: viewModel?.averageSessionLength ?? "0m",
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
    
    var chartPlaceholder: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Focus Time")
                    .font(.headline)
                Spacer()
            }
            
            // Placeholder chart area
            VStack {
                Spacer()
                
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(0..<7) { index in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.blue.opacity(0.3))
                            .frame(height: CGFloat.random(in: 40...120))
                    }
                }
                .frame(height: 150)
                
                Spacer()
                
                Text("Chart will display data in B-010")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
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
