//
//  SessionDetailView.swift
//  FocusFlow
//
//  Created by Okan Orkun on 18.10.2025.
//

import SwiftUI

struct SessionDetailView: View {
    let session: FocusSession
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                durationSection
                timeSection
                noteSection
            }
            .navigationTitle("Session Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done", action: dismiss.callAsFunction)
                }
            }
        }
    }
}

private extension SessionDetailView {
    var durationSection: some View {
        Section("Duration") {
            
            detailRow(
                icon: "clock.fill",
                color: .blue,
                label: "Focus Time",
                value: session.formattedDuration
            )
            
            
            if session.pauseCount > 0 {
                
                detailRow(
                    icon: "pause.circle.fill",
                    color: .orange,
                    label: "Pauses",
                    value: "\(session.pauseCount)"
                )
                
                detailRow(
                    icon: "timer",
                    color: .secondary,
                    label: "Paused Time",
                    value: Int(session.totalPauseDuration).formattedDuration()
                )
            }
        }
    }
    
    var timeSection: some View {
        Section("Time") {
            detailRow(
                icon: "calendar",
                color: .green,
                label: "Date",
                value: Date.formatDate(session.startTime)
            )
            
            detailRow(
                icon: "arrow.forward.circle.fill",
                color: .blue,
                label: "Started",
                value: Date.formatTime(session.startTime)
            )
            
            if let endTime = session.endTime {
                detailRow(
                    icon: "stop.circle.fill",
                    color: .red,
                    label: "Ended",
                    value: Date.formatTime(endTime)
                )
            }
        }
    }
    
    var noteSection: some View {
        Section("Note") {
            if session.note.isEmpty {
                Text("No note added")
                    .foregroundStyle(.secondary)
                    .italic()
            } else {
                Text(session.note)
                    .font(.body)
            }
        }
    }
}


private extension SessionDetailView {
    func detailRow(icon: String, color: Color, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(label)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}
