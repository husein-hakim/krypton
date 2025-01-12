//
//  CircularTimerViewModel.swift
//  Focus
//
//  Created by Husein Hakim on 19/12/24.
//

import SwiftUI
import Combine

class CircularTimerViewModel: ObservableObject {
    @Published var progress: Double = 0.0 // Progress of the circle (0.0 = start, 1.0 = full)
    @Published var minutesLeft: Int = 0
    @Published var secondsLeft: Int = 0
    
    var totalSeconds: Int // Total time in seconds
    private var elapsedSeconds: Int = 0
    private var timer: AnyCancellable?
    
    var onTimerComplete: (() -> Void)?
    
    init(totalMinutes: Double) {
        self.totalSeconds = Int(totalMinutes * 60)
        updateTimeComponents()
    }
    
    func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }
    
    private func tick() {
        guard elapsedSeconds < totalSeconds else {
            timer?.cancel()
            onTimerComplete?()// Stop the timer when completed
            return
        }
        
        elapsedSeconds += 1
        progress = Double(elapsedSeconds) / Double(totalSeconds) // Move forward
        print(progress)
        
        updateTimeComponents()
    }
    
    private func updateTimeComponents() {
        let remainingSeconds = totalSeconds - elapsedSeconds
        minutesLeft = remainingSeconds / 60
        secondsLeft = remainingSeconds % 60
    }
    
    func stopTimer() {
        timer?.cancel()
            timer = nil
        print("timer cancelled")
        }
}
