//
//  CustomWordRow.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2026-01-09.
//

import SwiftUI

/// A row displaying a custom word with its difficulty badge and hint category
struct CustomWordRow: View {
    @Environment(GameViewModel.self) private var viewModel
    let word: CustomWord

    private var categoryName: String? {
        guard let id = word.categoryId else { return nil }
        return viewModel.wordDataService.categories.first { $0.id == id }?.name
    }

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                // Word text
                Text(word.word)
                    .font(.body)
                    .foregroundStyle(.white)
                    .lineLimit(1)

                // Hint category, if tagged
                HStack(spacing: 4) {
                    Image(systemName: "lightbulb.fill")
                        .font(.caption2)
                    Text(categoryName ?? String(localized: "No hint"))
                        .font(.caption)
                }
                .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            // Difficulty badge
            Text(word.difficulty.shortName)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(difficultyColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(difficultyColor.opacity(0.2))
                )
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }

    private var difficultyColor: Color {
        switch word.difficulty {
        case .kids:
            return .green
        case .medium:
            return .blue
        case .hard:
            return .orange
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        CustomWordRow(word: CustomWord(word: "Apple", difficulty: .kids))
        CustomWordRow(word: CustomWord(word: "Cryptocurrency", difficulty: .hard))
        CustomWordRow(word: CustomWord(word: "Umbrella", difficulty: .medium))
    }
    .padding()
    .background(Color.darkBackground)
}
