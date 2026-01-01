//
//  DifficultyPickerView.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2025-12-31.
//

import SwiftUI

/// Multi-select difficulty picker
struct DifficultyPickerView: View {
    @Environment(GameViewModel.self) private var viewModel

    private var noneSelected: Bool {
        viewModel.settings.selectedDifficulties.isEmpty
    }

    var body: some View {
        VStack(spacing: 12) {
            // Header with status
            HStack {
                // Warning if none selected
                if noneSelected {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.caption)
                        Text("Select at least one")
                            .font(.caption)
                    }
                    .foregroundStyle(.orange)
                }

                Spacer()

                Button {
                    viewModel.settings.selectAllDifficulties()
                    viewModel.hapticsService.selection()
                } label: {
                    Text(viewModel.settings.allDifficultiesSelected ? "All Selected" : "Select All")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(viewModel.settings.allDifficultiesSelected ? .green : .purple)
                }
            }

            // Difficulty Options
            HStack(spacing: 12) {
                ForEach(Difficulty.allCases) { difficulty in
                    DifficultyChip(
                        difficulty: difficulty,
                        isSelected: viewModel.settings.selectedDifficulties.contains(difficulty),
                        onTap: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.settings.toggleDifficulty(difficulty)
                            }
                            viewModel.hapticsService.selection()
                        }
                    )
                }
            }
        }
    }
}

/// A single difficulty chip
struct DifficultyChip: View {
    let difficulty: Difficulty
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: difficulty.icon)
                    .font(.title2)

                Text(difficulty.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundStyle(isSelected ? .white : .white.opacity(0.5))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? chipColor.opacity(0.3) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                isSelected ? chipColor : Color.white.opacity(0.1),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(.bounce)
    }

    private var chipColor: Color {
        switch difficulty {
        case .kids: return .green
        case .medium: return .blue
        case .hard: return .orange
        }
    }
}

#Preview {
    VStack {
        DifficultyPickerView()
            .padding()
            .background(Color.elevatedBackground)
    }
    .padding()
    .background(Color.darkBackground)
    .environment(GameViewModel())
}
