//
//  CardBackView.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2025-12-31.
//

import SwiftUI

/// The back of the role card with mystery pattern
struct CardBackView: View {
    @State private var rotation: Double = 0
    @State private var shimmerPhase: CGFloat = 0

    var body: some View {
        ZStack {
            // Card background gradient
            RoundedRectangle(cornerRadius: Constants.cardCornerRadius)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.3, green: 0.2, blue: 0.5),
                            Color(red: 0.2, green: 0.15, blue: 0.4),
                            Color(red: 0.25, green: 0.1, blue: 0.45)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Pattern overlay
            GeometryReader { geometry in
                let columns = 5
                let rows = 7
                let spacing = geometry.size.width / CGFloat(columns)

                ForEach(0..<rows, id: \.self) { row in
                    ForEach(0..<columns, id: \.self) { col in
                        Image(systemName: "questionmark")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.15))
                            .rotationEffect(.degrees(Double((row + col) * 15)))
                            .position(
                                x: spacing * (CGFloat(col) + 0.5),
                                y: (geometry.size.height / CGFloat(rows)) * (CGFloat(row) + 0.5)
                            )
                    }
                }
            }

            // Central content
            VStack(spacing: 20) {
                // Animated question mark
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.purple.opacity(0.5), .clear],
                                center: .center,
                                startRadius: 20,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .blur(radius: 20)

                    // Question mark icon
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .rotationEffect(.degrees(rotation))
                        .shadow(color: .purple.opacity(0.5), radius: 10)
                }

                // Instruction text
                VStack(spacing: 8) {
                    Text("Swipe to Reveal")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)

                    HStack(spacing: 4) {
                        Image(systemName: "arrow.left")
                        Text("or")
                        Image(systemName: "arrow.right")
                    }
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                }
            }

            // Shimmer effect overlay
            GeometryReader { geometry in
                LinearGradient(
                    gradient: Gradient(colors: [
                        .clear,
                        .white.opacity(0.1),
                        .clear
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: geometry.size.width * 0.5)
                .offset(x: -geometry.size.width * 0.25 + shimmerPhase * geometry.size.width * 1.5)
                .mask(
                    RoundedRectangle(cornerRadius: Constants.cardCornerRadius)
                )
            }

            // Border
            RoundedRectangle(cornerRadius: Constants.cardCornerRadius)
                .strokeBorder(
                    LinearGradient(
                        colors: [.white.opacity(0.3), .white.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        }
        .onAppear {
            // Slow rotation animation
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                rotation = 360
            }

            // Shimmer animation
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                shimmerPhase = 1
            }
        }
    }
}

#Preview {
    CardBackView()
        .frame(width: 280, height: 420)
        .padding()
        .background(Color.darkBackground)
}
