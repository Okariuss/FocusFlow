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
            .onAppear {
                if viewModel == nil {
                    viewModel = TimerViewModel(modelContext: modelContext)
                }
            }
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
            
            Text("0m")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.primary)
        }
    }
    
    var timerDisplay: some View {
        VStack(spacing: 16) {
            Text(viewModel?.formattedTime ?? "00:00:00")
                .font(.system(size: 72, weight: .thin, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
            
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
            // TODO: Will be filled
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "pause.fill")
                    .font(.title3)
                
                Text("Pause")
                    .font(.body)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(.orange.opacity(0.2))
            .foregroundStyle(.orange)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }

    }
}

// MARK: Toolbar
private extension HomeView {
    var bottomToolbar: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            HStack(spacing: 0) {
                toolbarButton(icon: "clock.fill", title: "History")
                Spacer()
                toolbarButton(icon: "house.fill", title: "Home", isActive: true)
                Spacer()
                toolbarButton(icon: "chart.bar.fill", title: "Analytics")
            }
            .padding(.horizontal)
        }
    }
    
    func toolbarButton(icon: String, title: String, isActive: Bool = false) -> some View {
        Button {
            
        } label: {
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
