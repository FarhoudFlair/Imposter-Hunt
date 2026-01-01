//
//  RoleCardView.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2025-12-31.
//

import SwiftUI

/// The front of the role card showing the player's role
struct RoleCardView: View {
    let isImposter: Bool
    let word: String
    let categoryName: String
    let showHint: Bool

    @State private var hasAppeared = false

    var body: some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: Constants.cardCornerRadius)
                .fill(backgroundColor)

            // Subtle pattern overlay
            GeometryReader { geometry in
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(patternColor)
                        .frame(width: 200, height: 200)
                        .blur(radius: 60)
                        .offset(
                            x: CGFloat(i) * 100 - 100,
                            y: CGFloat(i) * 150 - 150
                        )
                }
            }
            .mask(RoundedRectangle(cornerRadius: Constants.cardCornerRadius))

            // Content
            VStack(spacing: 24) {
                Spacer()

                // Role Icon
                ZStack {
                    // Glow
                    Circle()
                        .fill(iconGlowColor)
                        .frame(width: 140, height: 140)
                        .blur(radius: 30)

                    Image(systemName: roleIcon)
                        .font(.system(size: 70))
                        .foregroundStyle(iconColor)
                        .scaleEffect(hasAppeared ? 1.0 : 0.5)
                        .opacity(hasAppeared ? 1.0 : 0.0)
                }

                // Role Text
                VStack(spacing: 8) {
                    Text(isImposter ? "You are" : "You are")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.8))

                    Text(isImposter ? "THE IMPOSTER" : "NOT the Imposter")
                        .font(.title)
                        .fontWeight(.heavy)
                        .foregroundStyle(textColor)
                        .multilineTextAlignment(.center)
                }
                .scaleEffect(hasAppeared ? 1.0 : 0.8)
                .opacity(hasAppeared ? 1.0 : 0.0)

                Spacer()

                // Word or Hint Section
                VStack(spacing: 12) {
                    if isImposter {
                        imposterContent
                    } else {
                        nonImposterContent
                    }
                }
                .padding(.horizontal, 20)
                .scaleEffect(hasAppeared ? 1.0 : 0.8)
                .opacity(hasAppeared ? 1.0 : 0.0)

                Spacer()
            }
            .padding(.vertical, 30)

            // Border
            RoundedRectangle(cornerRadius: Constants.cardCornerRadius)
                .strokeBorder(borderGradient, lineWidth: 3)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1)) {
                hasAppeared = true
            }
        }
    }

    // MARK: - Imposter Content

    @ViewBuilder
    private var imposterContent: some View {
        if showHint {
            VStack(spacing: 8) {
                Text("Category Hint")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))

                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(.yellow)
                    Text(categoryName)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.yellow)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.yellow.opacity(0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.yellow.opacity(0.3), lineWidth: 1)
                        )
                )
            }
        } else {
            VStack(spacing: 8) {
                Image(systemName: "eye.slash.fill")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.4))

                Text("No hint for you...")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
                    .italic()
            }
            .padding(.vertical, 20)
        }
    }

    // MARK: - Non-Imposter Content

    @ViewBuilder
    private var nonImposterContent: some View {
        VStack(spacing: 8) {
            Text("The secret word is")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))

            Text(word)
                .font(.system(size: 32, weight: .heavy))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )

            Text(categoryName)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
                .padding(.top, 4)
        }
    }

    // MARK: - Styling Properties

    private var backgroundColor: LinearGradient {
        if isImposter {
            return LinearGradient(
                colors: [
                    Color(red: 0.4, green: 0.1, blue: 0.1),
                    Color(red: 0.3, green: 0.05, blue: 0.05),
                    Color(red: 0.25, green: 0.05, blue: 0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.35, blue: 0.2),
                    Color(red: 0.05, green: 0.25, blue: 0.15),
                    Color(red: 0.05, green: 0.2, blue: 0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var patternColor: Color {
        isImposter ? .red.opacity(0.1) : .green.opacity(0.1)
    }

    private var roleIcon: String {
        isImposter ? "eye.slash.fill" : "checkmark.shield.fill"
    }

    private var iconColor: Color {
        isImposter ? .red : .green
    }

    private var iconGlowColor: Color {
        isImposter ? .red.opacity(0.3) : .green.opacity(0.3)
    }

    private var textColor: Color {
        isImposter ? .red : .green
    }

    private var borderGradient: LinearGradient {
        if isImposter {
            return LinearGradient(
                colors: [.red.opacity(0.6), .orange.opacity(0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [.green.opacity(0.6), .mint.opacity(0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

#Preview("Imposter with Hint") {
    RoleCardView(
        isImposter: true,
        word: "Elephant",
        categoryName: "Animals",
        showHint: true
    )
    .frame(width: 280, height: 420)
    .padding()
    .background(Color.darkBackground)
}

#Preview("Imposter without Hint") {
    RoleCardView(
        isImposter: true,
        word: "Elephant",
        categoryName: "Animals",
        showHint: false
    )
    .frame(width: 280, height: 420)
    .padding()
    .background(Color.darkBackground)
}

#Preview("Non-Imposter") {
    RoleCardView(
        isImposter: false,
        word: "Elephant",
        categoryName: "Animals",
        showHint: false
    )
    .frame(width: 280, height: 420)
    .padding()
    .background(Color.darkBackground)
}
