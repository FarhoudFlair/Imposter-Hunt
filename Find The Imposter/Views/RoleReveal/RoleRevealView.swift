//
//  RoleRevealView.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2025-12-31.
//

import SwiftUI

/// The main role reveal screen with the flippable card
struct RoleRevealView: View {
    @Environment(GameViewModel.self) private var viewModel

    @State private var hasAppeared = false

    var body: some View {
        VStack(spacing: 0) {
            // Player Name Header
            VStack(spacing: 4) {
                Text(playerName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                Text("Player \(viewModel.currentRevealIndex + 1) of \(viewModel.players.count)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(.top, 20)
            .opacity(hasAppeared ? 1 : 0)
            .offset(y: hasAppeared ? 0 : -10)

            Spacer()

            // The Card
            FlippableCardView(
                front: frontCard,
                back: CardBackView(),
                isFlipped: Binding(
                    get: { viewModel.isCardFlipped },
                    set: { _ in }
                ),
                onFlip: {
                    viewModel.flipCard()
                }
            )
            .frame(maxWidth: Constants.cardMaxWidth)
            .frame(height: Constants.cardMaxHeight)
            .scaleEffect(hasAppeared ? 1 : 0.9)
            .opacity(hasAppeared ? 1 : 0)

            Spacer()

            // Continue Button (only shown after flip)
            if viewModel.isCardFlipped {
                PrimaryButton(
                    viewModel.currentRevealIndex < viewModel.players.count - 1 ? "Next Player" : "Start Game",
                    icon: viewModel.currentRevealIndex < viewModel.players.count - 1 ? "arrow.right" : "play.fill"
                ) {
                    viewModel.moveToNextPlayer()
                }
                .padding(.horizontal, Constants.largePadding)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            Spacer()
                .frame(height: 30)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.isCardFlipped)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
                hasAppeared = true
            }
        }
        .onDisappear {
            hasAppeared = false
        }
    }

    private var playerName: String {
        guard let player = viewModel.currentPlayer else { return "Player" }
        return player.name.isEmpty ? "Player \(viewModel.currentRevealIndex + 1)" : player.name
    }

    @ViewBuilder
    private var frontCard: some View {
        if let player = viewModel.currentPlayer {
            RoleCardView(
                isImposter: player.isImposter,
                word: viewModel.selectedWord,
                categoryName: viewModel.selectedCategory?.name ?? "Unknown",
                showHint: viewModel.imposterGetsHint(for: player)
            )
        } else {
            // Fallback (shouldn't happen)
            RoleCardView(
                isImposter: false,
                word: "Error",
                categoryName: "Unknown",
                showHint: false
            )
        }
    }
}

#Preview {
    ZStack {
        AnimatedBackground()
        RoleRevealView()
    }
    .environment(GameViewModel())
}
