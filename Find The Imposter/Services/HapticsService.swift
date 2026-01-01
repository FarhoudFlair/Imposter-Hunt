//
//  HapticsService.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2025-12-31.
//

import UIKit

/// Service for providing haptic feedback
@Observable
class HapticsService {
    var isEnabled: Bool = true

    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let impactSoft = UIImpactFeedbackGenerator(style: .soft)
    private let impactRigid = UIImpactFeedbackGenerator(style: .rigid)
    private let notification = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()

    init() {
        prepareAll()
    }

    /// Prepare all generators for immediate response
    func prepareAll() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        impactSoft.prepare()
        impactRigid.prepare()
        notification.prepare()
        selectionGenerator.prepare()
    }

    /// Trigger impact feedback with specified style
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard isEnabled else { return }

        switch style {
        case .light:
            impactLight.impactOccurred()
            impactLight.prepare()
        case .medium:
            impactMedium.impactOccurred()
            impactMedium.prepare()
        case .heavy:
            impactHeavy.impactOccurred()
            impactHeavy.prepare()
        case .soft:
            impactSoft.impactOccurred()
            impactSoft.prepare()
        case .rigid:
            impactRigid.impactOccurred()
            impactRigid.prepare()
        @unknown default:
            impactMedium.impactOccurred()
            impactMedium.prepare()
        }
    }

    /// Trigger notification feedback
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isEnabled else { return }
        notification.notificationOccurred(type)
        notification.prepare()
    }

    /// Trigger selection feedback (subtle tap for selections)
    func selection() {
        guard isEnabled else { return }
        selectionGenerator.selectionChanged()
        selectionGenerator.prepare()
    }

    // MARK: - Convenience Methods

    /// Light tap for UI interactions
    func lightTap() {
        impact(.light)
    }

    /// Medium tap for confirmations
    func mediumTap() {
        impact(.medium)
    }

    /// Heavy tap for important actions
    func heavyTap() {
        impact(.heavy)
    }

    /// Success feedback
    func success() {
        notification(.success)
    }

    /// Warning feedback
    func warning() {
        notification(.warning)
    }

    /// Error feedback
    func error() {
        notification(.error)
    }
}
