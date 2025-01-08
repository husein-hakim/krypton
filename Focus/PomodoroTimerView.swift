//
//  PomodoroTimerView.swift
//  Focus
//
//  Created by Husein Hakim on 26/12/24.
//

import SwiftUI
import Foundation

struct PomodoroTimerView: View {
    @State var isStarted: Bool = false
    @State var workMinutes: Int = 15
    @State var breakMinutes: Int = 5
    
    var body: some View {
        if isStarted {
            PomodoroView(workMinutes: workMinutes, breakMinutes: breakMinutes, isStarted: $isStarted)
        } else {
            PomodoroSetupView(workMinutes: $workMinutes, breakMinutes: $breakMinutes, isStarted: $isStarted)
        }
    }
}

struct PomodoroSetupView: View {
    @Binding var workMinutes: Int
    @Binding var breakMinutes: Int
    @Binding var isStarted: Bool
    var body: some View {
        ZStack {
            Color.fPrimary.ignoresSafeArea()
            
            VStack {
                
                Spacer()
                
                HStack {
                    Text("Work: ")
                        .foregroundStyle(Color.fSecondary)
                        .font(.custom("SourceCodePro-Bold", size: 25))
                    
                    Picker("minutes", selection: $workMinutes) {
                        ForEach(15...60, id: \.self) { minute in
                            Text(String(minute))
                                .foregroundStyle(Color.fSecondary)
                                .font(.custom("SourceCodePro-Bold", size: 25))
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 100, height: 150)
                }
                
                HStack {
                    Text("Break: ")
                        .foregroundStyle(Color.fTertiary)
                        .font(.custom("SourceCodePro-Bold", size: 25))
                    
                    Picker("minutes", selection: $breakMinutes) {
                        ForEach(5...15, id: \.self) { minute in
                            Text(String(minute))
                                .foregroundStyle(Color.fTertiary)
                                .font(.custom("SourceCodePro-Bold", size: 25))
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 100, height: 100)
                }
                
                Button {
                    withAnimation {
                        isStarted = true
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundStyle(Color.fSecondary)

                        Text("Go Pomodoro!")
                            .foregroundStyle(Color.fText)
                            .font(.custom("SourceCodePro-Bold", size: 16))
                    }
                }
                .frame(width: 125, height: 35)
                
                Spacer()
            }
        }
    }
}

struct PomodoroView: View {
    @State var workMinutes: Int
    @State var breakMinutes: Int
    @Binding var isStarted: Bool
    @StateObject var timerViewModel = PomodoroTimerViewModel(workMinutes: 15, breakMinutes: 5)
    @Environment(\.scenePhase) var scenePhase

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
                        Spacer()
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
            timerViewModel.updateDurations(workMinutes: workMinutes, breakMinutes: breakMinutes)
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .background:
                timerViewModel.stopTimer()
                isStarted = false
                
            case .active:
                timerViewModel.startWorkSession()
                
            default:
                break
            }
        }
    }
}

#Preview {
    PomodoroTimerView()
}
