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
    @Environment(\.scenePhase) private var scenePhase

    /// Driven by settings so "Show Tutorial Again" re-presents without relaunch
    private var showOnboarding: Binding<Bool> {
        Binding(
            get: { !viewModel.settings.hasSeenOnboarding },
            set: { presented in
                if !presented {
                    viewModel.settings.hasSeenOnboarding = true
                }
            }
        )
    }

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

            if scenePhase != .active {
                privacyShield
                    .zIndex(100)
            }
        }
        .fullScreenCover(isPresented: showOnboarding) {
            OnboardingView()
        }
    }

    private var privacyShield: some View {
        ZStack {
            Color.darkBackground
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "eye.trianglebadge.exclamationmark.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .pink, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("IMPOSTER HUNT")
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundStyle(.white)
            }
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    ContentView()
        .environment(GameViewModel())
}
