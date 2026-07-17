//
//  OnboardingView.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2026-01-09.
//

import SwiftUI

/// Main onboarding container with paged TabView
struct OnboardingView: View {
    @Environment(GameViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss

    @State private var currentPage = 0

    /// Computed (not a stored default) so the category count reflects the live word
    /// bank instead of a number that goes stale whenever categories are added.
    private var pages: [OnboardingPage] {
        [
            OnboardingPage(
                icon: "eye.fill",
                iconColor: .purple,
                title: "Find The Imposter",
                subtitle: "The Party Word Game",
                description: "One player doesn't know the secret word. Can you find who it is before they blend in?"
            ),
            OnboardingPage(
                icon: "brain.head.profile",
                iconColor: .blue,
                title: "Strategic Hint System",
                subtitle: "Only If Starts Mode",
                description: "Only the starting imposter gets the category hint — creating real strategic tension and mind games."
            ),
            OnboardingPage(
                icon: "face.smiling",
                iconColor: .green,
                title: "Family Mode (Easy)",
                subtitle: "Easy for Everyone",
                description: "Family-friendly words and adjustable difficulty make it great for game nights with all ages."
            ),
            OnboardingPage(
                icon: "gift.fill",
                iconColor: .orange,
                title: "All Free",
                subtitle: "No Paywalls",
                description: "All \(viewModel.wordDataService.categories.count) categories included. No subscriptions, no ads, no in-app purchases. Just pure fun."
            )
        ]
    }

    var body: some View {
        ZStack {
            // Background
            AnimatedBackground()

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()

                    if currentPage < pages.count - 1 {
                        Button("Skip") {
                            completeOnboarding()
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(.horizontal, Constants.largePadding)
                        .padding(.top, 16)
                    }
                }
                .frame(height: 44)

                // Page content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        OnboardingPageView(
                            page: page,
                            isActive: currentPage == index
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Bottom section
                VStack(spacing: 24) {
                    // Page indicators
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? Color.white : Color.white.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .scaleEffect(currentPage == index ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                        }
                    }

                    // Action button
                    if currentPage == pages.count - 1 {
                        PrimaryButton("Get Started", icon: "arrow.right") {
                            completeOnboarding()
                        }
                        .padding(.horizontal, Constants.largePadding)
                    } else {
                        PrimaryButton("Next", icon: "arrow.right") {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                currentPage += 1
                            }
                        }
                        .padding(.horizontal, Constants.largePadding)
                    }
                }
                .padding(.bottom, 40)
            }
        }
    }

    private func completeOnboarding() {
        viewModel.settings.hasSeenOnboarding = true
        viewModel.hapticsService.success()
        dismiss()
    }
}

#Preview {
    OnboardingView()
        .environment(GameViewModel())
}
