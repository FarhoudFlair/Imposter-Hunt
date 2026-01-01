//
//  HomeView.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2025-12-31.
//

import SwiftUI

/// Main home screen with game title and start button
struct HomeView: View {
    @Environment(GameViewModel.self) private var viewModel

    @State private var titleScale: CGFloat = 0.8
    @State private var titleOpacity: Double = 0
    @State private var subtitleOffset: CGFloat = 20
    @State private var subtitleOpacity: Double = 0
    @State private var buttonOffset: CGFloat = 30
    @State private var buttonOpacity: Double = 0
    @State private var eyeRotation: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Logo and Title Section
            VStack(spacing: 20) {
                // Animated Eye Icon
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.purple.opacity(0.4), .clear],
                                center: .center,
                                startRadius: 20,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .blur(radius: 30)

                    // Eye icon
                    Image(systemName: "eye.trianglebadge.exclamationmark.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .pink, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .purple.opacity(0.5), radius: 15)
                        .rotationEffect(.degrees(eyeRotation))
                }
                .scaleEffect(titleScale)
                .opacity(titleOpacity)

                // Title
                VStack(spacing: 8) {
                    Text("IMPOSTER")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundStyle(.white.opacity(0.8))

                    Text("HUNT")
                        .font(.system(size: 48, weight: .black))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .purple.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .purple.opacity(0.5), radius: 10)
                }
                .scaleEffect(titleScale)
                .opacity(titleOpacity)

                // Subtitle
                Text("The Ultimate Party Word Game")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
                    .offset(y: subtitleOffset)
                    .opacity(subtitleOpacity)

                // Creator Credit
                Text("Created by Farhoud Talebi")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.4))
                    .offset(y: subtitleOffset)
                    .opacity(subtitleOpacity)
            }

            Spacer()
            Spacer()

            // Buttons Section
            VStack(spacing: 16) {
                PrimaryButton("Start Game", icon: "play.fill") {
                    viewModel.startNewGame()
                }

                SecondaryButton("Settings", icon: "gearshape.fill") {
                    viewModel.showSettings = true
                }
            }
            .padding(.horizontal, Constants.largePadding)
            .offset(y: buttonOffset)
            .opacity(buttonOpacity)

            Spacer()
                .frame(height: 50)
        }
        .sheet(isPresented: Binding(
            get: { viewModel.showSettings },
            set: { viewModel.showSettings = $0 }
        )) {
            SettingsView()
                .environment(viewModel)
        }
        .onAppear {
            animateIn()
        }
    }

    private func animateIn() {
        // Title and icon
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
            titleScale = 1.0
            titleOpacity = 1.0
        }

        // Subtitle
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3)) {
            subtitleOffset = 0
            subtitleOpacity = 1.0
        }

        // Buttons
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.4)) {
            buttonOffset = 0
            buttonOpacity = 1.0
        }

        // Subtle eye rotation
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            eyeRotation = 5
        }
    }
}

#Preview {
    ZStack {
        AnimatedBackground()
        HomeView()
    }
    .environment(GameViewModel())
}
