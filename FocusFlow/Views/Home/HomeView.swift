//
//  HomeView.swift
//  FocusFlow
//
//  Created by Okan Orkun on 16.10.2025.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: TimerViewModel?
    
    @State private var showHistory = false
    @State private var showAnalytics = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                todaysTotalSection
                    .padding(.top, 20)
                
                Spacer()
                
                timerDisplay
                
                Spacer()
                
                controlButtonsSection
                
                Spacer()
                    .frame(height: 20)
            }
            .navigationTitle("FocusFlow")
            .toolbar {
                bottomToolbar
            }
            .sheet(isPresented: $showHistory) {
                HistoryView()
            }
            .sheet(isPresented: $showAnalytics) {
                Text("Coming Soon")
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = TimerViewModel(modelContext: modelContext)
                }
            }
            .onChange(of: showHistory) { _, _ in }
        }
    }
}

// MARK: UI Sections
private extension HomeView {
    
    var todaysTotalSection: some View {
        VStack(spacing: 8) {
            Text("Today's Focus")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text(viewModel?.todaysTotalSecondsFormatted ?? "0s")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
        }
    }
    
    var timerDisplay: some View {
        VStack(spacing: 16) {
            Text(viewModel?.formattedTime ?? "00:00:00")
                .font(.system(size: 72, weight: .thin, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(viewModel?.isPaused == true ? .secondary : .primary)
                .contentTransition(.numericText())
                .animation(.easeInOut, value: viewModel?.isPaused)
            
            Text(viewModel?.statusText ?? "Ready to focus")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    var controlButtonsSection: some View {
        VStack(spacing: 20) {
            startStopButton
                .padding(.horizontal, 32)
            
            if viewModel?.isSessionActive == true {
                pauseButton
                    .padding(.horizontal, 32)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: viewModel?.isSessionActive)
        .animation(.easeInOut, value: viewModel?.isPaused)
    }
}

// MARK: Buttons
private extension HomeView {
    var startStopButton: some View {
        Button {
            handleMainButtonTap()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: viewModel?.isSessionActive == true ? "stop.fill" : "play.fill")
                    .font(.title2)
                
                Text(viewModel?.isSessionActive == true ? "Stop Session" : "Start Focus")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(viewModel?.isSessionActive == true ? .red : .blue)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: (viewModel?.isSessionActive == true ? Color.red : Color.blue).opacity(0.3), radius: 8, y: 4)
        }
    }
    
    var pauseButton: some View {
        Button {
            handlePauseResumeTap()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: viewModel?.isPaused == true ? "play.fill" : "pause.fill")
                    .font(.title3)
                
                Text(viewModel?.isPaused == true ? "Resume" : "Pause")
                    .font(.body)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(viewModel?.isPaused == true ? Color.blue.opacity(0.2) : Color.orange.opacity(0.2))
            .foregroundStyle(viewModel?.isPaused == true ? .green : .orange)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }

    }
}

// MARK: Toolbar
private extension HomeView {
    var bottomToolbar: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            HStack(spacing: 0) {
                toolbarButton(icon: "clock.fill", title: "History") {
                    showHistory = true
                }
                Spacer()
                toolbarButton(icon: "house.fill", title: "Home", isActive: true) {
                    
                }
                Spacer()
                toolbarButton(icon: "chart.bar.fill", title: "Analytics") {
                    showAnalytics = true
                }
            }
            .padding(.horizontal)
        }
    }
    
    func toolbarButton(icon: String, title: String, isActive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.caption)
            }
        }
        .frame(maxWidth: .infinity)
        .foregroundStyle(isActive ? .blue : .primary)
    }
    
    func handleMainButtonTap() {
        guard let viewModel else { return }
        
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        if viewModel.isSessionActive {
            viewModel.stopSession()
        } else {
            viewModel.startSession()
        }
    }
    
    func handlePauseResumeTap() {
        guard let viewModel else { return }
        
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        if viewModel.isPaused {
            viewModel.resumeSession()
        } else {
            viewModel.pauseSession()
        }
    }
}

// MARK: Previews
#Preview {
    HomeView()
        .modelContainer(for: [FocusSession.self, UserSettings.self])
}

#Preview("Dark") {
    HomeView()
        .modelContainer(for: [FocusSession.self, UserSettings.self])
        .preferredColorScheme(.dark)
}
