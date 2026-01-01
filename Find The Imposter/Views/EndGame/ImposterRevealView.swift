//
//  ImposterRevealView.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2025-12-31.
//

import SwiftUI

/// Dramatic imposter reveal animation
struct ImposterRevealView: View {
    @Environment(GameViewModel.self) private var viewModel
    let onContinue: () -> Void

    @State private var hasAppeared = false
    @State private var shakeOffset: CGFloat = 0
    @State private var glowOpacity: Double = 0

    var body: some View {
        VStack(spacing: 32) {
            // Dramatic Icon
            ZStack {
                // Pulsing glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.red.opacity(0.5), .clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)
                    .blur(radius: 30)
                    .opacity(glowOpacity)

                Image(systemName: "eye.slash.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.red, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .red.opacity(0.7), radius: 20)
                    .offset(x: shakeOffset)
            }
            .scaleEffect(hasAppeared ? 1.0 : 0.3)
            .opacity(hasAppeared ? 1.0 : 0)

            // Text
            VStack(spacing: 16) {
                Text(viewModel.imposters.count > 1 ? "The Imposters were..." : "The Imposter was...")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.7))

                // Imposter Names
                VStack(spacing: 8) {
                    ForEach(viewModel.imposters) { imposter in
                        Text(imposter.name.isEmpty ? "Unknown" : imposter.name)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.red, .orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                }
            }
            .opacity(hasAppeared ? 1.0 : 0)
            .offset(y: hasAppeared ? 0 : 20)

            // Continue Button
            PrimaryButton("Reveal the Word", icon: "text.bubble.fill") {
                onContinue()
            }
            .padding(.horizontal, 40)
            .opacity(hasAppeared ? 1.0 : 0)
            .offset(y: hasAppeared ? 0 : 30)
        }
        .onAppear {
            // Initial dramatic entrance
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5).delay(0.1)) {
                hasAppeared = true
            }

            // Shake effect
            withAnimation(.linear(duration: 0.05).repeatCount(8, autoreverses: true).delay(0.1)) {
                shakeOffset = 8
            }

            // Reset shake
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                shakeOffset = 0
            }

            // Pulsing glow
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true).delay(0.5)) {
                glowOpacity = 0.8
            }
        }
    }
}

#Preview {
    ZStack {
        AnimatedBackground()
        ImposterRevealView {}
    }
    .environment(GameViewModel())
}
