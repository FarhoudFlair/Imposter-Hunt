//
//  StartGameView.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2025-12-31.
//

import SwiftUI

/// Screen shown after all players have revealed, indicating who starts
struct StartGameView: View {
    @Environment(GameViewModel.self) private var viewModel

    @State private var iconScale: CGFloat = 0.5
    @State private var iconOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var textOffset: CGFloat = 20
    @State private var instructionsOpacity: Double = 0
    @State private var buttonOpacity: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Starting Player Announcement
            VStack(spacing: 24) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.green.opacity(0.3), .clear],
                                center: .center,
                                startRadius: 20,
                                endRadius: 100
                            )
                        )
                        .frame(width: 180, height: 180)
                        .blur(radius: 25)

                    Image(systemName: "hand.point.up.fill")
                        .font(.system(size: 70))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .green.opacity(0.5), radius: 15)
                }
                .scaleEffect(iconScale)
                .opacity(iconOpacity)

                // Text
                VStack(spacing: 12) {
                    Text("Let's Play!")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.7))

                    Text("\(startingPlayerName) starts!")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                }
                .offset(y: textOffset)
                .opacity(textOpacity)
            }

            Spacer()

            // Instructions
            VStack(spacing: 16) {
                Text("How to Play")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.8))

                VStack(alignment: .leading, spacing: 12) {
                    InstructionRow(number: 1, text: "Take turns describing the word without saying it")
                    InstructionRow(number: 2, text: "The imposter must blend in without knowing the word")
                    InstructionRow(number: 3, text: "Discuss and vote on who you think is the imposter")
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
                        .fill(Color.elevatedBackground)
                )
            }
            .padding(.horizontal, Constants.largePadding)
            .opacity(instructionsOpacity)

            Spacer()

            // End Game Button
            PrimaryButton("End Game", icon: "flag.fill", isDestructive: true) {
                viewModel.endGame()
            }
            .padding(.horizontal, Constants.largePadding)
            .opacity(buttonOpacity)

            Spacer()
                .frame(height: 50)
        }
        .onAppear {
            animateIn()
        }
    }

    private var startingPlayerName: String {
        guard let player = viewModel.startingPlayer else { return "Someone" }
        return player.name.isEmpty ? "Player \(viewModel.startingPlayerIndex + 1)" : player.name
    }

    private func animateIn() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
            iconScale = 1.0
            iconOpacity = 1.0
        }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3)) {
            textOffset = 0
            textOpacity = 1.0
        }

        withAnimation(.easeOut(duration: 0.4).delay(0.5)) {
            instructionsOpacity = 1.0
        }

        withAnimation(.easeOut(duration: 0.4).delay(0.6)) {
            buttonOpacity = 1.0
        }
    }
}

/// A single instruction row
struct InstructionRow: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(
                    Circle()
                        .fill(Color.purple)
                )

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
    }
}

#Preview {
    ZStack {
        AnimatedBackground()
        StartGameView()
    }
    .environment(GameViewModel())
}
