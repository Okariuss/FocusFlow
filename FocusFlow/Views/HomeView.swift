//
//  HomeView.swift
//  FocusFlow
//
//  Created by Okan Orkun on 16.10.2025.
//

import SwiftUI

struct HomeView: View {
    
    @State private var isSessionActive = false
    
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
            Text("00:00:00")
                .font(.system(size: 72, weight: .thin, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.primary)
            
            Text("Ready to focus")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    var controlButtonsSection: some View {
        VStack(spacing: 20) {
            startStopButton
                .padding(.horizontal, 32)
            
            if isSessionActive {
                pauseButton
                    .padding(.horizontal, 32)
            }
        }
    }
}

// MARK: Buttons
private extension HomeView {
    var startStopButton: some View {
        Button {
            isSessionActive.toggle()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: isSessionActive ? "stop.fill" : "play.fill")
                    .font(.title2)
                
                Text(isSessionActive ? "Stop Session" : "Start Focus")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(isSessionActive ? .red : .blue)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
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
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
            Text(title)
                .font(.caption)
        }
        .frame(maxWidth: .infinity)
        .foregroundStyle(isActive ? .blue : .primary)
    }
}

// MARK: Previews
#Preview {
    HomeView()
}

#Preview("Dark") {
    HomeView()
        .preferredColorScheme(.dark)
}
