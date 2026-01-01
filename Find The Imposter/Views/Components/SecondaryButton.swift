//
//  SecondaryButton.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2025-12-31.
//

import SwiftUI

/// Secondary button with outline style
struct SecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    var isDisabled: Bool = false

    init(
        _ title: String,
        icon: String? = nil,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isDisabled = isDisabled
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
                    .fontWeight(.medium)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: Constants.buttonCornerRadius)
                    .fill(Color.white.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: Constants.buttonCornerRadius)
                    .strokeBorder(.white.opacity(0.3), lineWidth: 1)
            )
            .opacity(isDisabled ? 0.5 : 1.0)
        }
        .buttonStyle(.bounce)
        .disabled(isDisabled)
    }
}

/// Compact icon button
struct IconButton: View {
    let icon: String
    let action: () -> Void
    var size: CGFloat = 44
    var color: Color = .white

    init(icon: String, color: Color = .white, size: CGFloat = 44, action: @escaping () -> Void) {
        self.icon = icon
        self.color = color
        self.size = size
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4))
                .foregroundStyle(color)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.1))
                )
                .overlay(
                    Circle()
                        .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                )
        }
        .buttonStyle(.bounce)
    }
}

#Preview {
    VStack(spacing: 20) {
        SecondaryButton("Settings", icon: "gearshape.fill") {
            print("Settings!")
        }

        SecondaryButton("Back", icon: "arrow.left") {
            print("Back!")
        }

        HStack(spacing: 16) {
            IconButton(icon: "plus") {
                print("Plus!")
            }

            IconButton(icon: "minus") {
                print("Minus!")
            }

            IconButton(icon: "xmark", color: .red) {
                print("Close!")
            }
        }
    }
    .padding()
    .background(Color.darkBackground)
}
