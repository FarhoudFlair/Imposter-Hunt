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

    let onBackToSettings: () -> Void

    @State private var hasAppeared = false
    @AccessibilityFocusState private var isRoleSummaryFocused: Bool

    init(onBackToSettings: @escaping () -> Void = {}) {
        self.onBackToSettings = onBackToSettings
    }

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
                front: frontCard
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(roleSummary)
                    .accessibilityFocused($isRoleSummaryFocused),
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

            // Reveal, continue, and cancellation controls
            VStack(spacing: 12) {
                if viewModel.isCardFlipped {
                    PrimaryButton(
                        viewModel.currentRevealIndex < viewModel.players.count - 1 ? "Next Player" : "Start Game",
                        icon: viewModel.currentRevealIndex < viewModel.players.count - 1 ? "arrow.right" : "play.fill"
                    ) {
                        viewModel.moveToNextPlayer()
                    }
                    .accessibilityIdentifier("role-reveal-next")
                } else {
                    PrimaryButton("Reveal Role", icon: "eye.fill") {
                        viewModel.flipCard()
                    }
                    .accessibilityIdentifier("reveal-role")
                }

                SecondaryButton("Back to Settings", icon: "arrow.left") {
                    onBackToSettings()
                }
                .accessibilityIdentifier("back-to-settings")
            }
            .padding(.horizontal, Constants.largePadding)
            .transition(.move(edge: .bottom).combined(with: .opacity))

            Spacer()
                .frame(height: 30)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.isCardFlipped)
        .onChange(of: viewModel.isCardFlipped) { _, isFlipped in
            isRoleSummaryFocused = isFlipped
        }
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

    private var roleSummary: String {
        guard let player = viewModel.currentPlayer else { return "Role unavailable" }

        if player.isImposter {
            if viewModel.shouldShowCategoryHint(for: player),
               let categoryName = viewModel.selectedCategory?.name {
                return "You are the Imposter. Category hint: \(categoryName)."
            }
            return "You are the Imposter. No category hint."
        }

        return "You are not the Imposter. The secret word is \(viewModel.selectedWord)."
    }

    @ViewBuilder
    private var frontCard: some View {
        if let player = viewModel.currentPlayer {
            RoleCardView(
                isImposter: player.isImposter,
                word: viewModel.selectedWord,
                categoryName: viewModel.selectedCategory?.name ?? "",
                showHint: viewModel.shouldShowCategoryHint(for: player)
            )
        } else {
            // Fallback (shouldn't happen)
            RoleCardView(
                isImposter: false,
                word: "Error",
                categoryName: "",
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
