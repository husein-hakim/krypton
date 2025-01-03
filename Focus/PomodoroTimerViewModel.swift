//
//  PomodoroTimerViewModel.swift
//  Focus
//
//  Created by Husein Hakim on 30/12/24.
//

import Foundation
import Combine
import SwiftUI

class PomodoroTimerViewModel: ObservableObject {
    @Published var progress: Double = 0.1
    @Published var minutesLeft: Int = 0
    @Published var secondsLeft: Int = 0
    @Published var isWorkSession: Bool = true // Indicates if it's a work session

    var totalSeconds: Int = 0
    var elapsedSeconds: Int = 0
    private var timer: AnyCancellable?

    private var workSessionDuration: Int // Work session duration in seconds
    var breakSessionDuration: Int // Break session duration in seconds
    
    var variableProgress: Double {
        return isWorkSession ? progress : 1 - progress
    }

    init(workMinutes: Double, breakMinutes: Double) {
        self.workSessionDuration = Int(workMinutes * 60)
        self.breakSessionDuration = Int(breakMinutes * 60)
        startWorkSession()
    }

    func startWorkSession() {
        isWorkSession = true
        totalSeconds = workSessionDuration
        resetTimer()
        startTimer()
    }

    func startBreakSession() {
        isWorkSession = false
        totalSeconds = breakSessionDuration
        resetTimer()
        startTimer()
    }

    private func resetTimer() {
        elapsedSeconds = 0
        progress = 0.0
        updateTimeComponents()
    }

    private func startTimer() {
        timer?.cancel() // Stop any existing timer
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func tick() {
        guard elapsedSeconds < totalSeconds else {
            timer?.cancel()
            switchToNextSession()
            return
        }

        elapsedSeconds += 1
        progress = (Double(elapsedSeconds) / Double(totalSeconds)) + 0.1
        updateTimeComponents()
    }

    private func updateTimeComponents() {
        let remainingSeconds = totalSeconds - elapsedSeconds
        minutesLeft = remainingSeconds / 60
        secondsLeft = remainingSeconds % 60
    }

    private func switchToNextSession() {
        if isWorkSession {
            startBreakSession()
        } else {
            startWorkSession()
        }
    }

    func stopTimer() {
        timer?.cancel()
        timer = nil
    }
}

