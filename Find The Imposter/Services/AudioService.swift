//
//  AudioService.swift
//  Find The Imposter
//
//  Created by Farhoud Talebi on 2025-12-31.
//

import AVFoundation

/// Service for playing sound effects
@Observable
class AudioService {
    var isEnabled: Bool = true

    private var audioPlayers: [Sound: AVAudioPlayer] = [:]

    enum Sound: String, CaseIterable {
        case cardFlip = "card_flip"
        case buttonTap = "button_tap"
        case reveal = "reveal"
        case imposterReveal = "imposter_reveal"
        case victory = "victory"
        case whoosh = "whoosh"
    }

    init() {
        setupAudioSession()
        preloadSounds()
    }

    private func setupAudioSession() {
        do {
            // Configure for game audio that respects silent mode
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    private func preloadSounds() {
        for sound in Sound.allCases {
            // Try mp3 first, then wav, then caf
            let extensions = ["mp3", "wav", "caf", "m4a"]
            for ext in extensions {
                if let url = Bundle.main.url(forResource: sound.rawValue, withExtension: ext) {
                    do {
                        let player = try AVAudioPlayer(contentsOf: url)
                        player.prepareToPlay()
                        player.volume = volumeForSound(sound)
                        audioPlayers[sound] = player
                        break
                    } catch {
                        print("Failed to load sound \(sound.rawValue).\(ext): \(error)")
                    }
                }
            }
        }
    }

    private func volumeForSound(_ sound: Sound) -> Float {
        switch sound {
        case .cardFlip: return 0.6
        case .buttonTap: return 0.4
        case .reveal: return 0.8
        case .imposterReveal: return 0.9
        case .victory: return 0.7
        case .whoosh: return 0.5
        }
    }

    func play(_ sound: Sound) {
        guard isEnabled else { return }

        DispatchQueue.main.async { [weak self] in
            if let player = self?.audioPlayers[sound] {
                player.currentTime = 0
                player.play()
            } else {
                // Sound file not found - this is okay during development
                // In production, all sounds should be included
                print("Sound not available: \(sound.rawValue)")
            }
        }
    }

    /// Stop all currently playing sounds
    func stopAll() {
        for player in audioPlayers.values {
            player.stop()
        }
    }
}
