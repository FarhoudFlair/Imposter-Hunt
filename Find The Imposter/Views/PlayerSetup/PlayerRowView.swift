//
//  PlayerRowView.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2025-12-31.
//

import SwiftUI

/// A single player input row
struct PlayerRowView: View {
    let playerNumber: Int
    @Binding var name: String
    let canRemove: Bool
    let isFocused: Bool
    let onRemove: () -> Void
    let onSubmit: () -> Void

    @State private var isShaking = false

    var body: some View {
        HStack(spacing: 12) {
            // Player Number Badge
            Text("\(playerNumber)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )

            // Text Field
            TextField("Player \(playerNumber)", text: $name)
                .font(.body)
                .foregroundStyle(.white)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                .submitLabel(.next)
                .onSubmit(onSubmit)

            // Remove Button
            if canRemove {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        isShaking = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        onRemove()
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.red.opacity(0.7))
                }
                .buttonStyle(.bounce)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .fill(Color.elevatedBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
                        .strokeBorder(
                            isFocused ? Color.purple.opacity(0.5) : Color.white.opacity(0.1),
                            lineWidth: isFocused ? 2 : 1
                        )
                )
        )
        .offset(x: isShaking ? -5 : 0)
        .onChange(of: isShaking) { _, shaking in
            if shaking {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isShaking = false
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        PlayerRowView(
            playerNumber: 1,
            name: .constant("Alice"),
            canRemove: true,
            isFocused: false,
            onRemove: {},
            onSubmit: {}
        )

        PlayerRowView(
            playerNumber: 2,
            name: .constant(""),
            canRemove: true,
            isFocused: true,
            onRemove: {},
            onSubmit: {}
        )

        PlayerRowView(
            playerNumber: 3,
            name: .constant("Charlie"),
            canRemove: false,
            isFocused: false,
            onRemove: {},
            onSubmit: {}
        )
    }
    .padding()
    .background(Color.darkBackground)
}
