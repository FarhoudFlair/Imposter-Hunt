//
//  PlayerSetupView.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2025-12-31.
//

import SwiftUI

/// Screen for entering player names
struct PlayerSetupView: View {
    @Environment(GameViewModel.self) private var viewModel
    @FocusState private var focusedPlayerIndex: Int?

    /// Computed property to force SwiftUI to observe all player names
    /// This creates a dependency that triggers view updates when any name changes
    private var allPlayerNamesHash: Int {
        viewModel.players.map { $0.name }.joined().hashValue
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        // Access hash to establish dependency on all player names
        let _ = allPlayerNamesHash

        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text("Who's Playing?")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                Text("\(viewModel.players.count) players")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(.top, 20)
            .padding(.bottom, 16)

            // Player List
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.players.indices, id: \.self) { index in
                        PlayerRowView(
                            playerNumber: index + 1,
                            name: $viewModel.players[index].name,
                            canRemove: viewModel.players.count > Constants.minPlayers,
                            isFocused: focusedPlayerIndex == index,
                            onRemove: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    viewModel.removePlayer(at: index)
                                }
                            },
                            onSubmit: {
                                if index < viewModel.players.count - 1 {
                                    focusedPlayerIndex = index + 1
                                } else {
                                    focusedPlayerIndex = nil
                                }
                            }
                        )
                        .focused($focusedPlayerIndex, equals: index)
                        .staggeredAnimation(index: index)
                    }

                    // Add Player Button
                    if viewModel.players.count < Constants.maxPlayers {
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.addPlayer()
                            }
                            // Focus the new player after a brief delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                focusedPlayerIndex = viewModel.players.count - 1
                            }
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                Text("Add Player")
                                    .font(.headline)
                            }
                            .foregroundStyle(.purple)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                                    .fill(Color.purple.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Constants.cornerRadius)
                                            .strokeBorder(Color.purple.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [8]))
                                    )
                            )
                        }
                        .buttonStyle(.bounce)
                        .padding(.top, 8)
                    }
                }
                .padding(.horizontal, Constants.largePadding)
                .padding(.bottom, 100)
            }

            Spacer()

            // Bottom Buttons
            VStack(spacing: 12) {
                PrimaryButton(
                    "Next",
                    icon: "arrow.right",
                    isDisabled: !viewModel.canProceedToGameSettings
                ) {
                    focusedPlayerIndex = nil
                    viewModel.proceedToSettings()
                }

                SecondaryButton("Back", icon: "arrow.left") {
                    viewModel.returnHome()
                }
            }
            .padding(.horizontal, Constants.largePadding)
            .padding(.bottom, Constants.largePadding)
            .background(
                LinearGradient(
                    colors: [.clear, Color.darkBackground],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 100)
                .offset(y: -50)
            )
        }
    }
}

#Preview {
    ZStack {
        AnimatedBackground()
        PlayerSetupView()
    }
    .environment(GameViewModel())
}
