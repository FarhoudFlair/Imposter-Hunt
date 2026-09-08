//
//  RoleRevealContainerView.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2025-12-31.
//

import SwiftUI

/// Container that manages the role reveal flow for all players
struct RoleRevealContainerView: View {
    @Environment(GameViewModel.self) private var viewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var isShowingReturnConfirmation = false

    var body: some View {
        ZStack {
            if viewModel.showPassPhoneScreen {
                PassPhoneView(onBackToSettings: requestReturnToSettings)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            } else {
                RoleRevealView(onBackToSettings: requestReturnToSettings)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            }
        }
        .animation(
            reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.8),
            value: viewModel.showPassPhoneScreen
        )
        .animation(
            reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.8),
            value: viewModel.currentRevealIndex
        )
        .alert("Return to Settings?", isPresented: $isShowingReturnConfirmation) {
            Button("Keep Playing", role: .cancel) {}
            Button("Return to Settings", role: .destructive) {
                viewModel.cancelRoleReveal()
            }
        } message: {
            Text("Revealed roles will be cleared and reassigned when you begin again.")
        }
    }

    private func requestReturnToSettings() {
        if viewModel.players.contains(where: \.hasRevealedRole) {
            isShowingReturnConfirmation = true
        } else {
            viewModel.cancelRoleReveal()
        }
    }
}

#Preview {
    ZStack {
        AnimatedBackground()
        RoleRevealContainerView()
    }
    .environment(GameViewModel())
}
