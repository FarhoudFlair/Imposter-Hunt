//
//  ContentView.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2025-12-31.
//

import SwiftUI

/// Root view that manages navigation between game phases
struct ContentView: View {
    @Environment(GameViewModel.self) private var viewModel

    var body: some View {
        ZStack {
            // Animated Background
            AnimatedBackground()

            // Content based on game phase
            Group {
                switch viewModel.gamePhase {
                case .home:
                    HomeView()
                        .transition(.opacity)

                case .playerSetup:
                    PlayerSetupView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))

                case .gameSettings:
                    GameSettingsView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))

                case .roleReveal:
                    RoleRevealContainerView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))

                case .playing:
                    StartGameView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))

                case .endGame:
                    EndGameView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.gamePhase)
        }
    }
}

#Preview {
    ContentView()
        .environment(GameViewModel())
}
