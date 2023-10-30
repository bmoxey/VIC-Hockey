//
//  VIC_HockeyApp.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 20/10/2023.
//

import SwiftUI
import SwiftData

@main
struct VIC_HockeyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Teams.self])
    }
}
