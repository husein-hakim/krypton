//
//  BreakTimerViewModel.swift
//  Focus
//
//  Created by Husein Hakim on 25/12/24.
//

import Foundation
import Combine
import SwiftUI

class BreakTimerViewModel: CircularTimerViewModel {
    @Published var isCooldownActive: Bool = false
    @Published var cooldownSecondsLeft: Int = 0
    private var cooldownTimer: Timer?

    var totalCooldownSeconds: Int = 0

    // Cooldown progress (0.0 to 1.0)
    var cooldownProgress: Double {
        guard totalCooldownSeconds > 0 else { return 0 }
        return 1 - (Double(cooldownSecondsLeft) / Double(totalCooldownSeconds))
    }
    
    var secondsUsed: Int {
        return Int(progress * Double(totalSeconds))
    }

    func startCooldown(cooldownMinutes: Double) {
        stopCooldown() // Stop any existing cooldowns
        cooldownSecondsLeft = Int(cooldownMinutes * 60)
        totalCooldownSeconds = cooldownSecondsLeft
        isCooldownActive = true

        cooldownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.cooldownTick()
        }
    }

    private func cooldownTick() {
        guard cooldownSecondsLeft > 0 else {
            stopCooldown()
            return
        }
        cooldownSecondsLeft -= 1
    }

    func stopCooldown() {
        cooldownTimer?.invalidate()
        cooldownTimer = nil
        isCooldownActive = false
        cooldownSecondsLeft = 0
        totalCooldownSeconds = 0
    }
    
    func resetTimer(totalMinutes: Double) {
        stopTimer()
        elapsedSeconds = 0
        progress = 0.0
        totalSeconds = Int(totalMinutes * 60)
        updateTimeComponents()
    }
}

