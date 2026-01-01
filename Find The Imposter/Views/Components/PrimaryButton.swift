//
//  PrimaryButton.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2025-12-31.
//

import SwiftUI

/// Primary call-to-action button with gradient background
struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    var isDisabled: Bool = false
    var isDestructive: Bool = false

    init(
        _ title: String,
        icon: String? = nil,
        isDisabled: Bool = false,
        isDestructive: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isDisabled = isDisabled
        self.isDestructive = isDestructive
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.headline)
                }
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: Constants.buttonCornerRadius)
                    .fill(backgroundGradient)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Constants.buttonCornerRadius)
                    .strokeBorder(.white.opacity(0.2), lineWidth: 1)
            )
            .opacity(isDisabled ? 0.5 : 1.0)
        }
        .buttonStyle(.bounce)
        .disabled(isDisabled)
    }

    private var backgroundGradient: LinearGradient {
        if isDestructive {
            return LinearGradient(
                colors: [.red, .orange],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
        return LinearGradient(
            colors: [.purple, .blue],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton("Start Game", icon: "play.fill") {
            print("Start!")
        }

        PrimaryButton("Next", icon: "arrow.right") {
            print("Next!")
        }

        PrimaryButton("Disabled Button", isDisabled: true) {
            print("Won't fire")
        }

        PrimaryButton("End Game", icon: "flag.fill", isDestructive: true) {
            print("End!")
        }
    }
    .padding()
    .background(Color.darkBackground)
}
