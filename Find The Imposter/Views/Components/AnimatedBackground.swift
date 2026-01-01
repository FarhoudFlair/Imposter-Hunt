//
//  AnimatedBackground.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2025-12-31.
//

import SwiftUI

/// Animated gradient background with floating orbs
struct AnimatedBackground: View {
    @State private var animationPhase: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.08, green: 0.06, blue: 0.15),
                        Color(red: 0.12, green: 0.08, blue: 0.22),
                        Color(red: 0.08, green: 0.1, blue: 0.18)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // Floating orbs
                ForEach(0..<5, id: \.self) { index in
                    Circle()
                        .fill(orbColor(for: index))
                        .frame(width: orbSize(for: index), height: orbSize(for: index))
                        .blur(radius: 40)
                        .opacity(0.3)
                        .offset(
                            x: orbOffset(
                                index: index,
                                phase: animationPhase,
                                size: geometry.size.width
                            ).x,
                            y: orbOffset(
                                index: index,
                                phase: animationPhase,
                                size: geometry.size.height
                            ).y
                        )
                }
            }
            .ignoresSafeArea()
        }
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                animationPhase = 1
            }
        }
    }

    private func orbColor(for index: Int) -> Color {
        let colors: [Color] = [.purple, .blue, .indigo, .cyan, .pink]
        return colors[index % colors.count]
    }

    private func orbSize(for index: Int) -> CGFloat {
        let sizes: [CGFloat] = [200, 180, 160, 140, 120]
        return sizes[index % sizes.count]
    }

    private func orbOffset(index: Int, phase: CGFloat, size: CGFloat) -> CGPoint {
        let baseOffset = CGFloat(index) * 0.2 * .pi
        let xPhase = sin((phase * 2 * .pi) + baseOffset) * size * 0.3
        let yPhase = cos((phase * 2 * .pi) + baseOffset + .pi / 4) * size * 0.3

        // Starting positions spread across the screen
        let startX = (CGFloat(index) / 5 - 0.5) * size
        let startY = (CGFloat(index % 3) / 3 - 0.5) * size

        return CGPoint(x: startX + xPhase, y: startY + yPhase)
    }
}

#Preview {
    AnimatedBackground()
}
