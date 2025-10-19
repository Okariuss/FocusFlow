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
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("History")
                .sheet(item: $selectedSession) { session in
                    SessionDetailView(session: session)
                }
                .onAppear(perform: setupViewModel)
//            .onAppear {
//                if viewModel == nil {
//                    viewModel = HistoryViewModel(modelContext: modelContext)
//                } else {
//                    viewModel?.loadSessions()
//                }
//            }
        }
    }
    
//    private func deleteSessionsInSection(_ sessions: [FocusSession], at offsets: IndexSet) {
//        guard let viewModel else { return }
//        
//        for index in offsets {
//            let session = sessions[index]
//            viewModel.deleteSession(session)
//        }
//    }
}

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
                        SessionRow(
                            session: session,
                            viewModel: viewModel!
                        )
                        .contentShape(.rect)
                        .onTapGesture {
                            selectedSession = session
                        }
                    }
                    .onDelete { deleteSessions(in: dateSection.1, at: $0) }
                }
            }
        }
        .listStyle(.insetGrouped)
        .refreshable { viewModel!.loadSessions() }
    }
    
    var emptyState: some View {
        ContentUnavailableView(
            "No Sessions Yet",
            systemImage: "clock.badge.questionmark",
            description: Text("Start a focus session to see it here")
        )
    }
}

private extension HistoryView {
    func setupViewModel() {
        if viewModel == nil {
            viewModel = HistoryViewModel(modelContext: modelContext)
        } else {
            viewModel?.loadSessions()
        }
    }
    
    func deleteSessions(in sessions: [FocusSession], at offsets: IndexSet) {
        guard let viewModel else { return }
        for index in offsets {
            viewModel.deleteSession(sessions[index])
        }
    }
}

#Preview {
    HistoryView()
}
