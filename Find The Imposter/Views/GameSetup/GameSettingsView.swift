//
//  GameSettingsView.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2025-12-31.
//

import SwiftUI

/// Pre-game configuration screen
struct GameSettingsView: View {
    @Environment(GameViewModel.self) private var viewModel

    var body: some View {
        VStack(spacing: 0) {
            // Header
            Text("Game Settings")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .padding(.top, 20)
                .padding(.bottom, 16)

            ScrollView {
                VStack(spacing: 24) {
                    // Imposter Count Section
                    SettingsSection(title: "Number of Imposters", icon: "eye.slash.fill") {
                        ImposterCountPicker(
                            count: Binding(
                                get: { viewModel.imposterCount },
                                set: { viewModel.imposterCount = $0 }
                            ),
                            maxCount: viewModel.maxImposters
                        )
                    }

                    // Imposter Hints Section
                    SettingsSection(title: "Imposter Hints", icon: "lightbulb.fill") {
                        VStack(alignment: .leading, spacing: 12) {
                            Picker("Hint Mode", selection: Binding(
                                get: { viewModel.settings.hintMode },
                                set: { viewModel.settings.hintMode = $0 }
                            )) {
                                ForEach(GameSettings.HintMode.allCases, id: \.self) { mode in
                                    Text(mode.displayName).tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)

                            Text(viewModel.settings.hintMode.description)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }

                    // Difficulty Section
                    SettingsSection(title: "Word Difficulty", icon: "flame.fill") {
                        DifficultyPickerView()
                    }

                    // Categories Section
                    SettingsSection(title: "Categories", icon: "square.grid.2x2.fill") {
                        CategoryPickerView()
                    }
                }
                .padding(.horizontal, Constants.largePadding)
                .padding(.bottom, 120)
            }

            Spacer()

            // Bottom Buttons
            VStack(spacing: 12) {
                // Warning if can't start
                if !viewModel.canStartGame {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text("Select at least one difficulty and category")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.orange.opacity(0.15))
                    )
                }

                PrimaryButton(
                    "Begin Game",
                    icon: "play.fill",
                    isDisabled: !viewModel.canStartGame
                ) {
                    viewModel.beginRoleReveal()
                }

                SecondaryButton("Back", icon: "arrow.left") {
                    viewModel.goBackFromSettings()
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

/// A section container for settings
struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(.purple)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.7))
            }

            // Section Content
            content()
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
                        .fill(Color.elevatedBackground)
                )
        }
    }
}

/// Imposter count picker
struct ImposterCountPicker: View {
    @Binding var count: Int
    let maxCount: Int

    var body: some View {
        HStack(spacing: 16) {
            // Decrease Button
            Button {
                if count > 1 {
                    count -= 1
                }
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.title)
                    .foregroundStyle(count > 1 ? .purple : .gray)
            }
            .disabled(count <= 1)

            // Count Display
            Text("\(count)")
                .font(.system(size: 48, weight: .bold))
                .foregroundStyle(.white)
                .frame(minWidth: 80)

            // Increase Button
            Button {
                if count < maxCount {
                    count += 1
                }
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title)
                    .foregroundStyle(count < maxCount ? .purple : .gray)
            }
            .disabled(count >= maxCount)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ZStack {
        AnimatedBackground()
        GameSettingsView()
    }
    .environment(GameViewModel())
}
