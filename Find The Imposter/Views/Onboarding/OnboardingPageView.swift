//
//  OnboardingPageView.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2026-01-09.
//

import SwiftUI

/// Data model for onboarding page content
struct OnboardingPage: Identifiable {
    let id = UUID()
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let description: String
}

/// Individual onboarding page with animated content
struct OnboardingPageView: View {
    let page: OnboardingPage
    let isActive: Bool

    @State private var hasAnimated = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon with glow effect
            ZStack {
                // Glow
                Circle()
                    .fill(page.iconColor.opacity(0.3))
                    .blur(radius: 40)
                    .frame(width: 160, height: 160)

                // Icon container
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [page.iconColor.opacity(0.3), page.iconColor.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .overlay(
                        Circle()
                            .strokeBorder(page.iconColor.opacity(0.5), lineWidth: 2)
                    )

                Image(systemName: page.icon)
                    .font(.system(size: 50, weight: .medium))
                    .foregroundStyle(page.iconColor)
            }
            .scaleEffect(hasAnimated ? 1.0 : 0.5)
            .opacity(hasAnimated ? 1.0 : 0.0)

            VStack(spacing: 16) {
                // Title
                Text(page.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                // Subtitle
                Text(page.subtitle)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(page.iconColor)
                    .multilineTextAlignment(.center)

                // Description
                Text(page.description)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .offset(y: hasAnimated ? 0 : 30)
            .opacity(hasAnimated ? 1.0 : 0.0)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, Constants.largePadding)
        .onChange(of: isActive) { _, newValue in
            if newValue {
                animateIn()
            } else {
                hasAnimated = false
            }
        }
        .onAppear {
            if isActive {
                animateIn()
            }
        }
    }

    private func animateIn() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            hasAnimated = true
        }
    }
}

#Preview {
    ZStack {
        AnimatedBackground()
        OnboardingPageView(
            page: OnboardingPage(
                icon: "eye.fill",
                iconColor: .purple,
                title: "Find The Imposter",
                subtitle: "The Party Word Game",
                description: "One player doesn't know the secret word. Can you find who it is before they blend in?"
            ),
            isActive: true
        )
    }
}
