//
//  AddWordRow.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2026-01-09.
//

import SwiftUI

/// Input row for adding a new custom word
struct AddWordRow: View {
    @Environment(GameViewModel.self) private var viewModel
    
    @State private var newWord: String = ""
    @State private var selectedDifficulty: Difficulty = .medium
    @State private var selectedCategoryId: String? = nil
    @State private var validationMessage: String?
    @FocusState private var isTextFieldFocused: Bool

    let onAdd: (String, Difficulty, String?) -> CustomWordService.AddWordResult

    private var selectedCategoryName: String {
        guard let id = selectedCategoryId,
              let category = viewModel.wordDataService.categories.first(where: { $0.id == id }) else {
            return String(localized: "No hint")
        }
        return category.name
    }

    var body: some View {
        VStack(spacing: 12) {
            // Text input
            HStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.purple)
                
                TextField("Enter a word...", text: $newWord)
                    .textFieldStyle(.plain)
                    .font(.body)
                    .foregroundStyle(.white)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                    .focused($isTextFieldFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        addWord()
                    }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .fill(Color.elevatedBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: Constants.cornerRadius)
                            .strokeBorder(
                                isTextFieldFocused ? Color.purple.opacity(0.5) : Color.white.opacity(0.1),
                                lineWidth: 1
                            )
                    )
            )

            if let validationMessage {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.circle.fill")
                    Text(validationMessage)
                }
                .font(.caption)
                .foregroundStyle(.orange)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Category hint picker (drives the imposter's hint for this word)
            Menu {
                Button {
                    selectedCategoryId = nil
                } label: {
                    Label("No hint", systemImage: selectedCategoryId == nil ? "checkmark" : "nosign")
                }
                Divider()
                ForEach(viewModel.wordDataService.categories) { category in
                    Button {
                        selectedCategoryId = category.id
                    } label: {
                        Label(category.name, systemImage: category.icon)
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(.yellow)
                    Text("Hint: \(selectedCategoryName)")
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.4))
                }
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
                        .fill(Color.elevatedBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                                .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
            }

            // Difficulty picker and add button
            HStack(spacing: 12) {
                // Difficulty picker
                Picker("Difficulty", selection: $selectedDifficulty) {
                    ForEach(Difficulty.allCases, id: \.self) { difficulty in
                        Text(difficulty.shortName).tag(difficulty)
                    }
                }
                .pickerStyle(.segmented)

                // Add button
                Button {
                    addWord()
                } label: {
                    Image(systemName: "plus")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 36)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: [.purple, .blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                }
                .buttonStyle(.bounce)
            }
        }
    }
    
    private func addWord() {
        switch onAdd(newWord, selectedDifficulty, selectedCategoryId) {
        case .added:
            validationMessage = nil
            viewModel.hapticsService.lightTap()
            newWord = ""
        case .empty:
            validationMessage = String(localized: "Enter a word.")
            viewModel.hapticsService.warning()
        case .tooLong:
            validationMessage = String(localized: "Keep words to 50 characters or fewer.")
            viewModel.hapticsService.warning()
        case .duplicate:
            validationMessage = String(localized: "That word is already in My Words.")
            viewModel.hapticsService.warning()
        }
    }
}

#Preview {
    VStack {
        AddWordRow { word, difficulty, categoryId in
            print("Added: \(word) (\(difficulty)) category: \(categoryId ?? "none")")
            return .added(CustomWord(word: word, difficulty: difficulty, categoryId: categoryId))
        }
    }
    .padding()
    .background(Color.darkBackground)
    .environment(GameViewModel())
}
