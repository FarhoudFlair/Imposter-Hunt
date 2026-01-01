//
//  WordRevealView.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2025-12-31.
//

import SwiftUI

/// The final word reveal with celebration
struct WordRevealView: View {
    @Environment(GameViewModel.self) private var viewModel

    @State private var hasAppeared = false
    @State private var wordScale: CGFloat = 0.5
    @State private var confettiTrigger = false

    var body: some View {
        VStack(spacing: 32) {
            // Victory Icon
            ZStack {
                // Glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.green.opacity(0.4), .clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .blur(radius: 25)

                Image(systemName: "party.popper.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .orange.opacity(0.5), radius: 15)
            }
            .scaleEffect(hasAppeared ? 1.0 : 0.5)
            .opacity(hasAppeared ? 1.0 : 0)

            // Word Reveal
            VStack(spacing: 16) {
                Text("The secret word was...")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.7))

                Text(viewModel.selectedWord)
                    .font(.system(size: 42, weight: .black))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .scaleEffect(wordScale)

                if let category = viewModel.selectedCategory {
                    HStack(spacing: 6) {
                        Image(systemName: category.icon)
                        Text(category.name)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.top, 4)
                }
            }
            .opacity(hasAppeared ? 1.0 : 0)

            // Summary
            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    Text("\(viewModel.players.count) players")
                    Text("•")
                    Text("\(viewModel.imposters.count) imposter\(viewModel.imposters.count > 1 ? "s" : "")")
                }
                .font(.caption)
                .foregroundStyle(.white.opacity(0.4))
            }
            .opacity(hasAppeared ? 1.0 : 0)
        }
        .overlay(
            // Confetti overlay
            ConfettiView(trigger: confettiTrigger)
        )
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                hasAppeared = true
            }

            withAnimation(.spring(response: 0.5, dampingFraction: 0.5).delay(0.3)) {
                wordScale = 1.0
            }

            // Trigger confetti
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                confettiTrigger = true
            }
        }
    }
}

/// Simple confetti effect
struct ConfettiView: View {
    let trigger: Bool

    @State private var particles: [ConfettiParticle] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .opacity(particle.opacity)
                }
            }
        }
        .onChange(of: trigger) { _, newValue in
            if newValue {
                createConfetti()
            }
        }
        .allowsHitTesting(false)
    }

    private func createConfetti() {
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]

        for i in 0..<50 {
            let startX = CGFloat.random(in: 50...350)
            let startY: CGFloat = -20
            let endY = CGFloat.random(in: 400...800)

            let particle = ConfettiParticle(
                id: i,
                color: colors.randomElement() ?? .white,
                size: CGFloat.random(in: 6...12),
                position: CGPoint(x: startX, y: startY),
                opacity: 1.0
            )

            particles.append(particle)

            // Animate particle falling
            let delay = Double(i) * 0.02
            withAnimation(.easeIn(duration: Double.random(in: 1.5...3.0)).delay(delay)) {
                if let index = particles.firstIndex(where: { $0.id == i }) {
                    particles[index].position = CGPoint(
                        x: startX + CGFloat.random(in: -100...100),
                        y: endY
                    )
                    particles[index].opacity = 0
                }
            }
        }

        // Clean up particles after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            particles.removeAll()
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id: Int
    let color: Color
    let size: CGFloat
    var position: CGPoint
    var opacity: Double
}

#Preview {
    ZStack {
        AnimatedBackground()
        WordRevealView()
    }
    .environment(GameViewModel())
}
