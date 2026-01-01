//
//  PassPhoneView.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2025-12-31.
//

import SwiftUI

/// Screen shown between players to pass the phone
struct PassPhoneView: View {
    @Environment(GameViewModel.self) private var viewModel

    @State private var iconScale: CGFloat = 0.5
    @State private var iconOpacity: Double = 0
    @State private var textOffset: CGFloat = 20
    @State private var textOpacity: Double = 0
    @State private var buttonOffset: CGFloat = 30
    @State private var buttonOpacity: Double = 0
    @State private var phoneRotation: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Progress indicator
            HStack(spacing: 8) {
                ForEach(0..<viewModel.players.count, id: \.self) { index in
                    Circle()
                        .fill(progressColor(for: index))
                        .frame(width: 10, height: 10)
                }
            }
            .padding(.bottom, 40)

            // Phone passing animation
            ZStack {
                // Glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.purple.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .blur(radius: 20)

                Image(systemName: "iphone.gen3")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .rotationEffect(.degrees(phoneRotation))
                    .shadow(color: .purple.opacity(0.5), radius: 10)
            }
            .scaleEffect(iconScale)
            .opacity(iconOpacity)

            Spacer()
                .frame(height: 40)

            // Instructions
            VStack(spacing: 12) {
                Text("Pass the phone to")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.7))

                if let player = viewModel.currentPlayer {
                    Text(player.name.isEmpty ? "Player \(viewModel.currentRevealIndex + 1)" : player.name)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.white)
                }

                Text("Player \(viewModel.currentRevealIndex + 1) of \(viewModel.players.count)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.top, 8)
            }
            .offset(y: textOffset)
            .opacity(textOpacity)

            Spacer()
            Spacer()

            // Ready Button
            PrimaryButton("I'm Ready", icon: "hand.tap.fill") {
                viewModel.playerReady()
            }
            .padding(.horizontal, Constants.largePadding)
            .offset(y: buttonOffset)
            .opacity(buttonOpacity)

            Spacer()
                .frame(height: 50)
        }
        .onAppear {
            animateIn()
        }
    }

    private func progressColor(for index: Int) -> Color {
        if index < viewModel.currentRevealIndex {
            return .green  // Completed
        } else if index == viewModel.currentRevealIndex {
            return .purple  // Current
        } else {
            return .white.opacity(0.3)  // Pending
        }
    }

    private func animateIn() {
        // Reset animation state
        iconScale = 0.5
        iconOpacity = 0
        textOffset = 20
        textOpacity = 0
        buttonOffset = 30
        buttonOpacity = 0
        phoneRotation = -15

        // Animate in
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1)) {
            iconScale = 1.0
            iconOpacity = 1.0
        }

        withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.2)) {
            textOffset = 0
            textOpacity = 1.0
        }

        withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.3)) {
            buttonOffset = 0
            buttonOpacity = 1.0
        }

        // Phone wobble
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            phoneRotation = 15
        }
    }
}

#Preview {
    ZStack {
        AnimatedBackground()
        PassPhoneView()
    }
    .environment(GameViewModel())
}
