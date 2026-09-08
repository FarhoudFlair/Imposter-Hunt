//
//  PrivacyPolicyView.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2026-07-16.
//

import SwiftUI

/// Local privacy policy shown without requiring a network connection.
struct PrivacyPolicyView: View {
    var body: some View {
        ZStack {
            Color.darkBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.purple)

                    Text("Your Privacy")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)

                    VStack(alignment: .leading, spacing: 18) {
                        policyStatement("Imposter Hunt works entirely offline.")
                        policyStatement("The app has no accounts.")
                        policyStatement(
                            "The app does not collect, transmit, sell, share, or track personal data."
                        )
                        policyStatement(
                            "Settings and custom words stay on the device in UserDefaults. Player names stay in memory for the current session only."
                        )
                        policyStatement("Deleting the app removes its locally stored data.")
                        policyStatement(
                            "Privacy questions can be sent through the developer contact shown on the App Store listing."
                        )
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: Constants.cornerRadius)
                            .fill(Color.elevatedBackground)
                    )
                }
                .padding(Constants.largePadding)
            }
            .accessibilityIdentifier("privacy-policy")
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.darkBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private func policyStatement(_ text: String) -> some View {
        Text(text)
            .font(.body)
            .foregroundStyle(.white.opacity(0.8))
            .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
}
