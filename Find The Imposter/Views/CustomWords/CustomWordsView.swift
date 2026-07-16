//
//  CustomWordsView.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2026-01-09.
//

import SwiftUI

/// View for managing user-created custom words
struct CustomWordsView: View {
    @Environment(GameViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.darkBackground
                    .ignoresSafeArea()

                List {
                    // Add word section
                    Section {
                        AddWordRow { word, difficulty in
                            viewModel.customWordService.addWord(word, difficulty: difficulty)
                        }
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(
                            top: 8,
                            leading: Constants.largePadding,
                            bottom: 8,
                            trailing: Constants.largePadding
                        ))
                        .listRowSeparator(.hidden)
                    }

                    // Words list or empty state
                    if viewModel.customWordService.hasWords {
                        Section {
                            ForEach(viewModel.customWordService.customWords) { word in
                                CustomWordRow(word: word)
                                    .listRowBackground(
                                        RoundedRectangle(cornerRadius: Constants.cornerRadius)
                                            .fill(Color.elevatedBackground)
                                            .padding(.vertical, 4)
                                    )
                                    .listRowInsets(EdgeInsets(
                                        top: 4,
                                        leading: Constants.largePadding,
                                        bottom: 4,
                                        trailing: Constants.largePadding
                                    ))
                                    .listRowSeparator(.hidden)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            deleteWord(id: word.id)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            deleteWord(id: word.id)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        } header: {
                            HStack {
                                Text("Your Words")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .textCase(nil)

                                Spacer()

                                Text("\(viewModel.customWordService.wordCount) words")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.5))
                                    .textCase(nil)
                            }
                        }
                    } else {
                        Section {
                            VStack(spacing: 16) {
                                Image(systemName: "text.badge.plus")
                                    .font(.system(size: 50))
                                    .foregroundStyle(.white.opacity(0.3))

                                Text("Add your own words for a personalized game!")
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.5))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Custom Words")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
            .toolbarBackground(Color.darkBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    private func deleteWord(id: UUID) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            viewModel.customWordService.removeWord(id: id)
        }
        viewModel.hapticsService.mediumTap()
    }
}

#Preview {
    CustomWordsView()
        .environment(GameViewModel())
}
