//
//  BouncyModifier.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2025-12-31.
//

import SwiftUI

/// Modifier that adds a bouncy entrance animation
struct BouncyEntranceModifier: ViewModifier {
    @State private var hasAppeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let delay: Double

    func body(content: Content) -> some View {
        content
            .scaleEffect(reduceMotion ? 1.0 : (hasAppeared ? 1.0 : 0.5))
            .opacity(reduceMotion ? 1.0 : (hasAppeared ? 1.0 : 0.0))
            .onAppear {
                appear()
            }
            .onChange(of: reduceMotion) { _, shouldReduceMotion in
                if shouldReduceMotion {
                    hasAppeared = true
                }
            }
    }

    private func appear() {
        guard !reduceMotion else {
            hasAppeared = true
            return
        }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(delay)) {
            hasAppeared = true
        }
    }
}

/// Modifier for staggered list animations
struct StaggeredAnimationModifier: ViewModifier {
    let index: Int
    let baseDelay: Double
    @State private var hasAppeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .offset(y: reduceMotion ? 0 : (hasAppeared ? 0 : 20))
            .opacity(reduceMotion ? 1.0 : (hasAppeared ? 1.0 : 0.0))
            .onAppear {
                appear()
            }
            .onChange(of: reduceMotion) { _, shouldReduceMotion in
                if shouldReduceMotion {
                    hasAppeared = true
                }
            }
    }

    private func appear() {
        guard !reduceMotion else {
            hasAppeared = true
            return
        }

        withAnimation(.spring(response: 0.4, dampingFraction: 0.7).delay(baseDelay + Double(index) * 0.05)) {
            hasAppeared = true
        }
    }
}

/// Modifier for scale-in animation
struct ScaleInModifier: ViewModifier {
    @State private var hasAppeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let delay: Double

    func body(content: Content) -> some View {
        content
            .scaleEffect(reduceMotion ? 1.0 : (hasAppeared ? 1.0 : 0.8))
            .opacity(reduceMotion ? 1.0 : (hasAppeared ? 1.0 : 0.0))
            .onAppear {
                appear()
            }
            .onChange(of: reduceMotion) { _, shouldReduceMotion in
                if shouldReduceMotion {
                    hasAppeared = true
                }
            }
    }

    private func appear() {
        guard !reduceMotion else {
            hasAppeared = true
            return
        }

        withAnimation(.easeOut(duration: 0.3).delay(delay)) {
            hasAppeared = true
        }
    }
}

/// Modifier for slide-up animation
struct SlideUpModifier: ViewModifier {
    @State private var hasAppeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let delay: Double

    func body(content: Content) -> some View {
        content
            .offset(y: reduceMotion ? 0 : (hasAppeared ? 0 : 30))
            .opacity(reduceMotion ? 1.0 : (hasAppeared ? 1.0 : 0.0))
            .onAppear {
                appear()
            }
            .onChange(of: reduceMotion) { _, shouldReduceMotion in
                if shouldReduceMotion {
                    hasAppeared = true
                }
            }
    }

    private func appear() {
        guard !reduceMotion else {
            hasAppeared = true
            return
        }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(delay)) {
            hasAppeared = true
        }
    }
}

// MARK: - View Extensions

extension View {
    /// Add a bouncy entrance animation
    func bouncyEntrance(delay: Double = 0) -> some View {
        modifier(BouncyEntranceModifier(delay: delay))
    }

    /// Add a staggered list animation
    func staggeredAnimation(index: Int, baseDelay: Double = 0) -> some View {
        modifier(StaggeredAnimationModifier(index: index, baseDelay: baseDelay))
    }

    /// Add a scale-in animation
    func scaleIn(delay: Double = 0) -> some View {
        modifier(ScaleInModifier(delay: delay))
    }

    /// Add a slide-up animation
    func slideUp(delay: Double = 0) -> some View {
        modifier(SlideUpModifier(delay: delay))
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Bouncy!")
            .font(.title)
            .bouncyEntrance()

        ForEach(0..<5, id: \.self) { index in
            Text("Item \(index + 1)")
                .padding()
                .background(Color.purple.opacity(0.3))
                .cornerRadius(8)
                .staggeredAnimation(index: index)
        }
    }
    .padding()
    .background(Color.darkBackground)
}
