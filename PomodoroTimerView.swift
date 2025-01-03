//
//  PomodoroTimerView.swift
//  Focus
//
//  Created by Husein Hakim on 26/12/24.
//

import SwiftUI
import Foundation

struct PomodoroTimerView: View {
    @StateObject var timerViewModel = PomodoroTimerViewModel(workMinutes: 1, breakMinutes: 1)

    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .foregroundStyle(Color.fPrimary)
                .ignoresSafeArea()
            
            Rectangle()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .foregroundStyle(Color.fSecondary)
                .ignoresSafeArea()
                .mask(
                    VStack {
                        Spacer() // Push the mask rectangle to the bottom
                        Rectangle()
                            .frame(height: timerViewModel.variableProgress * UIScreen.main.bounds.height)
                            .animation(.linear(duration: TimeInterval(timerViewModel.isWorkSession ? timerViewModel.totalSeconds : timerViewModel.breakSessionDuration)), value: timerViewModel.variableProgress)
                           .ignoresSafeArea()
                    }
                )
            
            VStack {
                HStack {
                    Text("\(timerViewModel.minutesLeft)")
                    Text(":")
                    Text("\(timerViewModel.secondsLeft)")
                }
                
                Text(timerViewModel.isWorkSession ? "Work" : "Break")
            }
        }
        .onAppear {
            print("timer started")
        }
    }
}

#Preview {
    PomodoroTimerView()
}
