//
//  View+Animations.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2025-12-31.
//

import SwiftUI

extension View {
    /// Apply a bouncy spring animation
    func bouncy() -> some View {
        self.modifier(
            ReducedMotionAnimationModifier(
                animation: .spring(response: 0.4, dampingFraction: 0.6)
            )
        )
    }

    /// Apply a smooth spring animation
    func smoothSpring() -> some View {
        self.modifier(
            ReducedMotionAnimationModifier(
                animation: .spring(response: 0.5, dampingFraction: 0.8)
            )
        )
    }

    /// Apply card flip animation
    func cardFlipAnimation() -> some View {
        self.modifier(
            ReducedMotionAnimationModifier(
                animation: .spring(response: 0.6, dampingFraction: 0.7)
            )
        )
    }

    /// Add a subtle pulsing effect
    func pulsing() -> some View {
        self.modifier(PulsingModifier())
    }

    /// Add a floating effect
    func floating(duration: Double = 2.0, distance: CGFloat = 5) -> some View {
        self.modifier(FloatingModifier(duration: duration, distance: distance))
    }

    /// Add a shimmer effect
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }

    /// Conditional modifier
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Animation Modifiers
struct ReducedMotionAnimationModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let animation: Animation

    func body(content: Content) -> some View {
        content.animation(reduceMotion ? nil : animation, value: UUID())
    }
}


struct PulsingModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(reduceMotion ? 1.0 : (isPulsing ? 1.05 : 1.0))
            .animation(
                reduceMotion ? nil : .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = !reduceMotion
            }
            .onChange(of: reduceMotion) { _, shouldReduceMotion in
                isPulsing = !shouldReduceMotion
            }
    }
}

struct FloatingModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let duration: Double
    let distance: CGFloat
    @State private var isFloating = false

    func body(content: Content) -> some View {
        content
            .offset(y: reduceMotion ? 0 : (isFloating ? -distance : distance))
            .animation(
                reduceMotion ? nil : .easeInOut(duration: duration).repeatForever(autoreverses: true),
                value: isFloating
            )
            .onAppear {
                isFloating = !reduceMotion
            }
            .onChange(of: reduceMotion) { _, shouldReduceMotion in
                isFloating = !shouldReduceMotion
            }
    }
}

struct ShimmerModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .clear,
                            .white.opacity(0.3),
                            .clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: -geometry.size.width + (phase * geometry.size.width * 2))
                }
            )
            .mask(content)
            .onAppear {
                startAnimation()
            }
            .onChange(of: reduceMotion) { _, _ in
                startAnimation()
            }
    }

    private func startAnimation() {
        guard !reduceMotion else {
            phase = 0
            return
        }

        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            phase = 1
        }
    }
}

// MARK: - Bounce Button Style

struct BounceButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(reduceMotion ? 1.0 : (configuration.isPressed ? 0.95 : 1.0))
            .animation(
                reduceMotion ? nil : .spring(response: 0.2, dampingFraction: 0.6),
                value: configuration.isPressed
            )
    }
}

extension ButtonStyle where Self == BounceButtonStyle {
    static var bounce: BounceButtonStyle { BounceButtonStyle() }
}
