//
//  SessionRow.swift
//  FocusFlow
//
//  Created by Okan Orkun on 18.10.2025.
//

import SwiftUI

struct SessionRow: View {
    let session: FocusSession
    let viewModel: HistoryViewModel

    var body: some View {
        HStack(spacing: 16) {
            sessionInfo
            Spacer()
            chevron
        }
        .padding(.vertical, 8)
    }
}

private extension SessionRow {
    var sessionInfo: some View {
        VStack(alignment: .leading, spacing: 6) {
            timeRow
            durationText
            noteText
            pauseInfo
        }
    }

    var timeRow: some View {
        HStack(spacing: 8) {
            Image(systemName: "clock.fill")
                .font(.caption)
                .foregroundStyle(.blue)

            Text(Date.formatTime(session.startTime))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    var durationText: some View {
        Text(session.formattedDuration)
            .font(.title3)
            .fontWeight(.semibold)
    }

    var noteText: some View {
        Group {
            if !session.note.isEmpty {
                Text(session.note)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
    }

    var pauseInfo: some View {
        Group {
            if session.pauseCount > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "pause.circle.fill")
                        .font(.caption2)
                    Text("Paused \(session.pauseCount) time\(session.pauseCount == 1 ? "" : "s")")
                        .font(.caption2)
                }
                .foregroundStyle(.orange)
            }
        }
    }

    var chevron: some View {
        Image(systemName: "chevron.right")
            .font(.caption)
            .foregroundStyle(.tertiary)
    }
}
