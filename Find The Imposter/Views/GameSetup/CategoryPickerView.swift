//
//  CategoryPickerView.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2025-12-31.
//

import SwiftUI

/// Multi-select grid for word categories
struct CategoryPickerView: View {
    @Environment(GameViewModel.self) private var viewModel
    @State private var isExpanded = false

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

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
                } else {
                    Text("\(selectedCount) of \(totalCount) selected")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }

                Spacer()

                Button {
                    let allIds = Set(viewModel.wordDataService.categories.map { $0.id })
                    viewModel.settings.selectAllCategories(allIds: allIds)
                    viewModel.hapticsService.selection()
                } label: {
                    Text(allSelected ? "All Selected" : "Select All")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(allSelected ? .green : .purple)
                }
            }

            // Expand/Collapse Button
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
                viewModel.hapticsService.lightTap()
            } label: {
                HStack {
                    Text(isExpanded ? "Hide Categories" : "Show Categories")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
                .foregroundStyle(.white.opacity(0.7))
                .padding(.vertical, 8)
            }

            // Category Grid
            if isExpanded {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(viewModel.wordDataService.categories) { category in
                        CategoryChip(
                            category: category,
                            isSelected: isCategorySelected(category.id),
                            onTap: {
                                toggleCategory(category.id)
                            }
                        )
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .onAppear {
            initializeCategoriesIfNeeded()
        }
    }

    private var totalCount: Int {
        viewModel.wordDataService.categories.count
    }

    private var selectedCount: Int {
        viewModel.settings.selectedCategoryIds.count
    }

    private var noneSelected: Bool {
        viewModel.settings.selectedCategoryIds.isEmpty
    }

    private var allSelected: Bool {
        selectedCount == totalCount
    }

    private func isCategorySelected(_ categoryId: String) -> Bool {
        viewModel.settings.selectedCategoryIds.contains(categoryId)
    }

    private func toggleCategory(_ categoryId: String) {
        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
            viewModel.settings.toggleCategory(categoryId)
        }
        viewModel.hapticsService.selection()
    }

    private func initializeCategoriesIfNeeded() {
        let allIds = Set(viewModel.wordDataService.categories.map { $0.id })
        viewModel.settings.initializeCategoriesIfNeeded(allIds: allIds)
    }
}

/// A single category chip
struct CategoryChip: View {
    let category: Category
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.title3)

                Text(category.name)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(isSelected ? .white : .white.opacity(0.4))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? categoryColor.opacity(0.25) : Color.white.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(
                                isSelected ? categoryColor.opacity(0.6) : Color.white.opacity(0.08),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(.bounce)
    }

    private var categoryColor: Color {
        Color.forCategory(category.id)
    }
}

#Preview {
    VStack {
        CategoryPickerView()
            .padding()
            .background(Color.elevatedBackground)
    }
    .padding()
    .background(Color.darkBackground)
    .environment(GameViewModel())
}
