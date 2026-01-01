//
//  SettingsView.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2025-12-31.
//

import SwiftUI

/// App settings sheet for sound and haptics
struct SettingsView: View {
    @Environment(GameViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.darkBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Sound Setting
                        SettingsToggleRow(
                            icon: viewModel.settings.soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill",
                            iconColor: viewModel.settings.soundEnabled ? .green : .gray,
                            title: "Sound Effects",
                            subtitle: "Play sounds during gameplay",
                            isOn: Binding(
                                get: { viewModel.settings.soundEnabled },
                                set: { _ in viewModel.toggleSound() }
                            )
                        )

                        // Haptics Setting
                        SettingsToggleRow(
                            icon: viewModel.settings.hapticsEnabled ? "iphone.radiowaves.left.and.right" : "iphone",
                            iconColor: viewModel.settings.hapticsEnabled ? .purple : .gray,
                            title: "Haptic Feedback",
                            subtitle: "Feel vibrations during interactions",
                            isOn: Binding(
                                get: { viewModel.settings.hapticsEnabled },
                                set: { _ in viewModel.toggleHaptics() }
                            )
                        )

                        Spacer()
                            .frame(height: 20)

                        // App Info
                        VStack(spacing: 8) {
                            Text("Find The Imposter")
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.6))

                            Text("Version 1.0")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.4))
                        }
                        .padding(.top, 20)
                    }
                    .padding(Constants.largePadding)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
            .toolbarBackground(Color.darkBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

/// A toggle row for settings
struct SettingsToggleRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(iconColor)
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(iconColor.opacity(0.15))
                )

            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            // Toggle
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.purple)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .fill(Color.elevatedBackground)
        )
    }
}

#Preview {
    SettingsView()
        .environment(GameViewModel())
}
