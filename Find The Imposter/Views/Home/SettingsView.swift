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
    @State private var showCustomWords = false

    private var customWordsSubtitle: String {
        let count = viewModel.customWordService.wordCount
        if count == 0 {
            return "Add your own words"
        } else {
            return "\(count) word\(count == 1 ? "" : "s") added"
        }
    }

    private var versionText: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "2"
        return "Version \(version) (\(build))"
    }

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

                        // Divider
                        Rectangle()
                            .fill(.white.opacity(0.1))
                            .frame(height: 1)
                            .padding(.vertical, 8)

                        // Show Tutorial Again
                        Button {
                            viewModel.settings.hasSeenOnboarding = false
                            viewModel.hapticsService.lightTap()
                            dismiss()
                        } label: {
                            HStack(spacing: 16) {
                                Image(systemName: "book.pages")
                                    .font(.title2)
                                    .foregroundStyle(.blue)
                                    .frame(width: 44, height: 44)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.blue.opacity(0.15))
                                    )

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Show Tutorial Again")
                                        .font(.headline)
                                        .foregroundStyle(.white)

                                    Text("Review the app features")
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.5))
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.3))
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                                    .fill(Color.elevatedBackground)
                            )
                        }
                        .buttonStyle(.bounce)

                        // Privacy Policy
                        NavigationLink {
                            PrivacyPolicyView()
                        } label: {
                            HStack(spacing: 16) {
                                Image(systemName: "hand.raised.fill")
                                    .font(.title2)
                                    .foregroundStyle(.purple)
                                    .frame(width: 44, height: 44)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.purple.opacity(0.15))
                                    )

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Privacy Policy")
                                        .font(.headline)
                                        .foregroundStyle(.white)

                                    Text("How your local data is handled")
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.5))
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.3))
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                                    .fill(Color.elevatedBackground)
                            )
                        }
                        .accessibilityLabel("Privacy Policy")
                        .buttonStyle(.bounce)

                        // Custom Words
                        Button {
                            showCustomWords = true
                        } label: {
                            HStack(spacing: 16) {
                                Image(systemName: "heart.text.square")
                                    .font(.title2)
                                    .foregroundStyle(.pink)
                                    .frame(width: 44, height: 44)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.pink.opacity(0.15))
                                    )

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Custom Words")
                                        .font(.headline)
                                        .foregroundStyle(.white)

                                    Text(customWordsSubtitle)
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.5))
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.3))
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                                    .fill(Color.elevatedBackground)
                            )
                        }
                        .buttonStyle(.bounce)

                        Spacer()
                            .frame(height: 20)

                        // App Info
                        VStack(spacing: 8) {
                            Text("Imposter Hunt")
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.6))

                            Text(versionText)
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
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $showCustomWords) {
            CustomWordsView()
        }
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue(isOn ? "On" : "Off")
    }
}

#Preview {
    SettingsView()
        .environment(GameViewModel())
}
