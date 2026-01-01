//
//  EndGameView.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2025-12-31.
//

import SwiftUI

/// End game screen with sequential reveals
struct EndGameView: View {
    @Environment(GameViewModel.self) private var viewModel

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Content based on reveal state
            if !viewModel.showImposterReveal {
                // Initial state - ready to reveal
                ReadyToRevealView {
                    viewModel.revealImposters()
                }
            } else if !viewModel.showWordReveal {
                // Imposter revealed, word pending
                ImposterRevealView {
                    viewModel.revealWord()
                }
            } else {
                // Both revealed
                WordRevealView()
            }

            Spacer()

            // Bottom buttons (only show after word reveal)
            if viewModel.showWordReveal {
                VStack(spacing: 12) {
                    PrimaryButton("Play Again", icon: "arrow.counterclockwise") {
                        viewModel.playAgain()
                    }

                    SecondaryButton("Home", icon: "house.fill") {
                        viewModel.returnHome()
                    }
                }
                .padding(.horizontal, Constants.largePadding)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            Spacer()
                .frame(height: 50)
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.showImposterReveal)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.showWordReveal)
    }
}

/// Initial state before any reveals
struct ReadyToRevealView: View {
    let onReveal: () -> Void

    @State private var hasAppeared = false
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 32) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.orange.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 100
                        )
                    )
                    .frame(width: 180, height: 180)
                    .blur(radius: 25)

                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .yellow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(pulseScale)
                    .shadow(color: .orange.opacity(0.5), radius: 15)
            }
            .scaleEffect(hasAppeared ? 1.0 : 0.5)
            .opacity(hasAppeared ? 1.0 : 0)

            // Text
            VStack(spacing: 12) {
                Text("Game Over!")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.white)

                Text("Ready to see who the imposter was?")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .opacity(hasAppeared ? 1.0 : 0)
            .offset(y: hasAppeared ? 0 : 20)

            // Reveal Button
            PrimaryButton("Reveal Imposter", icon: "eye.fill") {
                onReveal()
            }
            .padding(.horizontal, 40)
            .opacity(hasAppeared ? 1.0 : 0)
            .offset(y: hasAppeared ? 0 : 30)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                hasAppeared = true
            }

            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulseScale = 1.1
            }
        }
    }
}

#Preview {
    ZStack {
        AnimatedBackground()
        EndGameView()
    }
    .environment(GameViewModel())
}
