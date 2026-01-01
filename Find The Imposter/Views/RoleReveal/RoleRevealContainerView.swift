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

    var body: some View {
        ZStack {
            if viewModel.showPassPhoneScreen {
                PassPhoneView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            } else {
                RoleRevealView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.showPassPhoneScreen)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.currentRevealIndex)
    }
}

#Preview {
    ZStack {
        AnimatedBackground()
        RoleRevealContainerView()
    }
    .environment(GameViewModel())
}
