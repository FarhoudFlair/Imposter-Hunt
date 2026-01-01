//
//  Find_The_ImposterApp.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2025-12-31.
//

import SwiftUI

@main
struct Find_The_ImposterApp: App {
    @State private var gameViewModel = GameViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(gameViewModel)
                .preferredColorScheme(.dark)
        }
    }
}
