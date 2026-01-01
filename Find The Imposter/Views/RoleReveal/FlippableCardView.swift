//
//  FlippableCardView.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2025-12-31.
//

import SwiftUI

/// A card that flips with a 3D rotation animation controlled by swipe gesture
struct FlippableCardView<Front: View, Back: View>: View {
    let front: Front
    let back: Back
    @Binding var isFlipped: Bool
    var onFlip: (() -> Void)?

    // The current rotation angle (0 = back showing, 180 = front showing)
    @State private var rotation: Double = 0
    // Track if we're currently dragging
    @State private var isDragging: Bool = false
    // The drag translation during gesture
    @State private var dragTranslation: CGFloat = 0

    // How many degrees per point of drag
    private let rotationSensitivity: Double = 0.5
    // Maximum rotation from drag before auto-completing
    private let maxDragRotation: Double = 180
    // Threshold rotation to commit the flip (past 90 degrees commits)
    private let commitThreshold: Double = 90

    var body: some View {
        GeometryReader { geometry in
            let cardWidth = min(geometry.size.width - 40, Constants.cardMaxWidth)
            let cardHeight = min(geometry.size.height - 40, Constants.cardMaxHeight)

            // Calculate effective rotation (base + drag contribution)
            let effectiveRotation = min(maxDragRotation, max(0, rotation + abs(Double(dragTranslation)) * rotationSensitivity))

            ZStack {
                // Back of card (mystery side) - visible when rotation < 90
                back
                    .frame(width: cardWidth, height: cardHeight)
                    .opacity(effectiveRotation < 90 ? 1 : 0)

                // Front of card (role reveal side) - visible when rotation >= 90
                front
                    .frame(width: cardWidth, height: cardHeight)
                    .rotation3DEffect(
                        .degrees(180),
                        axis: (x: 0, y: 1, z: 0)
                    )
                    .opacity(effectiveRotation >= 90 ? 1 : 0)
            }
            .rotation3DEffect(
                .degrees(effectiveRotation),
                axis: (x: 0, y: 1, z: 0),
                anchor: .center,
                anchorZ: 0,
                perspective: 0.35
            )
            // Subtle Z-axis tilt for more realistic feel
            .rotation3DEffect(
                .degrees(isDragging ? Double(dragTranslation) * 0.015 : 0),
                axis: (x: 0, y: 0, z: 1)
            )
            // Slight scale effect when dragging
            .scaleEffect(isDragging ? 1.02 : 1.0)
            .frame(width: geometry.size.width, height: geometry.size.height)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        guard !isFlipped else { return }
                        isDragging = true
                        dragTranslation = value.translation.width
                    }
                    .onEnded { value in
                        guard !isFlipped else { return }
                        isDragging = false

                        let finalRotation = rotation + abs(Double(dragTranslation)) * rotationSensitivity

                        if finalRotation >= commitThreshold {
                            // Commit the flip - animate to 180
                            completeFlip()
                        } else {
                            // Snap back - animate to 0
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                dragTranslation = 0
                            }
                        }
                    }
            )
            .onChange(of: isFlipped) { _, newValue in
                if newValue && rotation < 180 {
                    completeFlip()
                } else if !newValue {
                    // Reset when isFlipped becomes false
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        rotation = 0
                        dragTranslation = 0
                    }
                }
            }
            .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.8), value: isDragging)
        }
    }

    private func completeFlip() {
        // Calculate remaining rotation needed
        let currentRotation = rotation + abs(Double(dragTranslation)) * rotationSensitivity
        let remainingRotation = 180 - currentRotation

        // Duration proportional to remaining rotation (faster if almost there)
        let duration = max(0.2, remainingRotation / 180 * 0.5)

        withAnimation(.spring(response: duration, dampingFraction: 0.75)) {
            rotation = 180
            dragTranslation = 0
            isFlipped = true
        }
        onFlip?()
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var isFlipped = false

        var body: some View {
            VStack {
                FlippableCardView(
                    front: RoundedRectangle(cornerRadius: 24)
                        .fill(Color.green)
                        .overlay(Text("FRONT").foregroundStyle(.white)),
                    back: RoundedRectangle(cornerRadius: 24)
                        .fill(Color.purple)
                        .overlay(Text("BACK - Swipe me!").foregroundStyle(.white)),
                    isFlipped: $isFlipped
                ) {
                    print("Flipped!")
                }
                .frame(height: 400)

                Button("Reset") {
                    withAnimation {
                        isFlipped = false
                    }
                }
                .padding()
            }
            .padding()
            .background(Color.darkBackground)
        }
    }

    return PreviewWrapper()
}
