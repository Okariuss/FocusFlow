//
//  SessionNoteView.swift
//  FocusFlow
//
//  Created by Okan Orkun on 21.10.2025.
//

import SwiftUI
import SwiftData

struct SessionNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var viewModel: SessionNoteViewModel?
    @FocusState private var isTextFieldFocused: Bool
    
    let session: FocusSession
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Session Note")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    toolbarContent
                }
                .onAppear {
                    setupViewModel()
                    isTextFieldFocused = true
                }
        }
    }
}

// MARK: Content
private extension SessionNoteView {
    var content: some View {
        VStack(alignment: .leading, spacing: 16) {
            sessionInfoCard
            noteEditor
            Spacer()
        }
        .padding()
    }
    
    var sessionInfoCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundStyle(.blue)
                Text(session.formattedDuration)
                    .font(.headline)
                
                Spacer()
                
                Text(Date.formatDate(session.startTime))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    var noteEditor: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("What did you work on?")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            TextEditor(text: Binding(
                get: { viewModel?.noteText ?? "" },
                set: { viewModel?.noteText = $0 }
            ))
            .focused($isTextFieldFocused)
            .frame(minHeight: 150)
            .padding(8)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
    }
}

// MARK: Toolbar
private extension SessionNoteView {
    var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    handleCancel()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    handleSave()
                }
                .disabled(!(viewModel?.canSave ?? false))
            }
        }
    }
}

// MARK: Actions
private extension SessionNoteView {
    func setupViewModel() {
        if viewModel == nil {
            viewModel = SessionNoteViewModel(session: session, modelContext: modelContext)
        }
    }
    
    func handleSave() {
        viewModel?.saveNote()
        dismiss()
    }
    
    func handleCancel() {
        if viewModel?.hasChanges == true {
            viewModel?.discardChanges()
        }
        dismiss()
    }
}
