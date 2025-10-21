//
//  HistoryView.swift
//  FocusFlow
//
//  Created by Okan Orkun on 18.10.2025.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var viewModel: HistoryViewModel?
    @State private var selectedSession: FocusSession?
    
    private let deleteSession = ConfirmationConfig.deleteSession
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("History")
                .sheet(item: $selectedSession) { session in
                    SessionDetailView(session: session)
                }
                .alert(
                    deleteSession.title,
                    isPresented: Binding(
                        get: { viewModel?.showDeleteConfirmation ?? false },
                        set: { if !$0 { viewModel?.cancelDelete() } }
                    )
                ) {
                    alertButtons
                } message: {
                    Text(deleteSession.message)
                }
                .onAppear(perform: setupViewModel)
        }
    }
}

// MARK: - Content
private extension HistoryView {
    var content: some View {
        Group {
            if let viewModel, !viewModel.sessions.isEmpty {
                sessionList
            } else {
                emptyState
            }
        }
    }
    
    var sessionList: some View {
        List {
            ForEach(viewModel!.sessionsByDate(), id: \.0) { dateSection in
                Section(header: Text(dateSection.0)) {
                    ForEach(dateSection.1) { session in
                        sessionRow(for: session)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .refreshable { viewModel?.loadSessions() }
    }
    
    var emptyState: some View {
        ContentUnavailableView(
            "No Sessions Yet",
            systemImage: "clock.badge.questionmark",
            description: Text("Start a focus session to see it here")
        )
    }
    
    func sessionRow(for session: FocusSession) -> some View {
        SessionRow(session: session, viewModel: viewModel!)
            .contentShape(.rect)
            .swipeActions(edge: .trailing) {
                Button {
                    viewModel?.requestDeleteSession(session)
                } label: {
                    Label(deleteSession.confirmTitle, systemImage: "trash")
                }
                .tint(.red)
            }
            .onTapGesture {
                selectedSession = session
            }
    }
}

// MARK: - Alert Buttons
private extension HistoryView {
    var alertButtons: some View {
        Group {
            Button(deleteSession.confirmTitle, role: .destructive) {
                viewModel?.confirmDelete()
            }
            
            Button(deleteSession.cancelTitle, role: .cancel) {
                viewModel?.cancelDelete()
            }
        }
    }
}

// MARK: - Actions
private extension HistoryView {
    func setupViewModel() {
        if viewModel == nil {
            viewModel = HistoryViewModel(modelContext: modelContext)
        } else {
            viewModel?.loadSessions()
        }
    }
}

// MARK: - Preview
#Preview("With Sessions") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: FocusSession.self, UserSettings.self,
        configurations: config
    )
    let context = ModelContext(container)
    
    for i in 0..<3 {
        let session = FocusSession(
            startTime: Date().addingTimeInterval(TimeInterval(-i * 3600)),
            endTime: Date().addingTimeInterval(TimeInterval(-i * 3600 + 1800)),
            note: "Session \(i + 1)"
        )
        context.insert(session)
    }
    
    return HistoryView()
        .modelContainer(container)
}

#Preview("Empty") {
    HistoryView()
        .modelContainer(for: [FocusSession.self, UserSettings.self])
}
