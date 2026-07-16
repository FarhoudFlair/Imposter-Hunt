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
    @FocusState private var isTextFieldFocused: Bool
    
    let onAdd: (String, Difficulty) -> Void
    
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
            
            // Difficulty picker and add button
            HStack(spacing: 12) {
                // Difficulty picker
                Picker("Difficulty", selection: $selectedDifficulty) {
                    ForEach(Difficulty.allCases, id: \.self) { difficulty in
                        Text(difficulty.displayName).tag(difficulty)
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
                .disabled(newWord.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(newWord.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)
            }
        }
    }
    
    private func addWord() {
        let trimmed = newWord.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        
        onAdd(trimmed, selectedDifficulty)
        viewModel.hapticsService.lightTap()
        newWord = ""
    }
}

#Preview {
    VStack {
        AddWordRow { word, difficulty in
            print("Added: \(word) (\(difficulty))")
        }
    }
    .padding()
    .background(Color.darkBackground)
    .environment(GameViewModel())
}
