//
//  simpliApp.swift
//  simpli
//
//  Created by Victor on 03/02/2026.
//

import SwiftUI

@main
struct simpliApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)  // Force dark mode (status bar, nav bar, system views)
                .tint(AppTheme.dark.primary) // Global accent for buttons, links, toggles
                .appTheme(.dark)             // Inject theme into environment for child views
        }
    }
}
