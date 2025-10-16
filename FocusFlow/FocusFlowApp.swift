//
//  FocusFlowApp.swift
//  FocusFlow
//
//  Created by Okan Orkun on 16.10.2025.
//

import SwiftUI
import SwiftData

@main
struct FocusFlowApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            FocusSession.self,
            UserSettings.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
