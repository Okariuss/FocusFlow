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
    
    @State private var showNoteEditor = false
    
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
            .sheet(isPresented: $showNoteEditor) {
                SessionNoteView(session: session)
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
                Button {
                    showNoteEditor = true
                } label: {
                    HStack {
                        Text("Add a note")
                            .foregroundStyle(.blue)
                        Spacer()
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.blue)
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text(session.note)
                        .font(.body)
                    
                    Button {
                        showNoteEditor = true
                    } label: {
                        Text("Edit")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }
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
