//
//  PomodoroTimerView.swift
//  Focus
//
//  Created by Husein Hakim on 26/12/24.
//

import SwiftUI
import Foundation

struct PomodoroTimerView: View {
    @State var workMinutes: Int = 1
    @State var breakMinutes: Int = 1
    @State var isStarted: Bool = false
    @State var selectedKrypton: String = "krypton"
    @State var options: Bool = false
    
    var body: some View {
        ZStack {
            Color.fPrimary.ignoresSafeArea()
            
            VStack {
                
                Spacer()
                
                HStack {
                    Text("Krypton: ")
                        .foregroundStyle(Color.fTertiary)
                        .font(.custom("SourceCodePro-Bold", size: 25))
                    
                    Image(selectedKrypton)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 75, height: 75)
                        .onTapGesture {
                            options = true
                        }
                }
                
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
                
                Text("Each Session you will earn: \(String(format: "%.0f", floor(Double(workMinutes/15)))) kryptons")
                    .font(.custom("SourceCodePro-Regular", size: 18))
                    .foregroundStyle(Color.fText)
                
                Spacer()
            }
        }
        .fullScreenCover(isPresented: $isStarted) {
            PomodoroView(workMinutes: workMinutes, breakMinutes: breakMinutes, isStarted: $isStarted, selectedKrypton: selectedKrypton)
        }
        .sheet(isPresented: $options) {
            SpriteSelectView(selectedKrypton: $selectedKrypton)
                .presentationDetents([.medium])
        }
    }
}

struct PomodoroView: View {
    @State var workMinutes: Int
    @State var breakMinutes: Int
    @Binding var isStarted: Bool
    @StateObject var timerViewModel = PomodoroTimerViewModel(workMinutes: 15, breakMinutes: 5)
    @State var isGame: Bool = false
    @Environment(\.scenePhase) var scenePhase
    @State var playing: Bool = false
    @State var kryptonsEarned: Int = 0
    @State var selectedKrypton: String
    @State var kryptoAvailability: Bool?
    
    @StateObject private var audioPlayer = AudioPlayer()

    var body: some View {
        NavigationStack {
            ZStack {
                Rectangle()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .foregroundStyle(Color.fPrimary)
                    .ignoresSafeArea()
                
                VStack {
                    
                    Spacer()
                    
                    Rectangle()
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                        .foregroundStyle(Color.fSecondary)
                        .ignoresSafeArea()
                        .mask(
                            VStack {
                                Spacer()
                                Rectangle()
                                    .frame(height: timerViewModel.variableProgress * (UIScreen.main.bounds.height*1.05))
                                    .animation(.linear(duration: TimeInterval(timerViewModel.isWorkSession ? timerViewModel.totalSeconds : timerViewModel.breakSessionDuration)), value: timerViewModel.variableProgress)
                                    .ignoresSafeArea()
                            }
                        )
                }
                
                VStack {
                    HStack {
                        Text("\(timerViewModel.minutesLeft)")
                            .font(.custom("SourceCodePro-Bold", size: 30))
                            .foregroundStyle(Color.fText)
                        Text(":")
                            .font(.custom("SourceCodePro-Bold", size: 30))
                            .foregroundStyle(Color.fText)
                        Text("\(timerViewModel.secondsLeft)")
                            .font(.custom("SourceCodePro-Bold", size: 30))
                            .foregroundStyle(Color.fText)
                    }
                    
                    Text(timerViewModel.isWorkSession ? "Keep Working!" : "Time to rest")
                        .foregroundStyle(Color.fText)
                        .font(.custom("SourceCodePro-Bold", size: 25))
                    
                    Button {
                        Task {
                            isStarted = false
                        }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color.red)
                                .frame(width: 100, height: 50)
                            
                            Text("Give Up")
                                .font(.custom("SourceCodePro-Bold", size: 16))
                                .foregroundStyle(Color.black)
                        }
                    }
                    .frame(width: 75, height: 50)
                    .padding()
                    
                    if !timerViewModel.isWorkSession {
                        Button {
                            isGame = true
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(Color.fTertiary)
                                    .frame(width: 100, height: 50)
                                
                                Text("Play")
                                    .font(.custom("SourceCodePro-Bold", size: 16))
                                    .foregroundStyle(Color.black)
                            }
                        }

                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if playing {
                            audioPlayer.stopAllSounds()
                        } else {
                            audioPlayer.playSound(fileName: "forest", fileType: "wav")
                        }
                        
                        playing.toggle()
                    } label: {
                        Image(systemName: playing ? "headphones" : "headphones.slash")
                            .foregroundStyle(Color.black)
                    }

                }
                
                ToolbarItem(placement: .topBarLeading) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 100, height: 50)
                            .foregroundStyle(Color.fSecondary)
                            .opacity(0.5)
                        
                        HStack {
                            Image(selectedKrypton)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .padding(.leading, 1)
                            
                            Spacer()
                            
                            Text("\(kryptonsEarned)")
                                .font(.custom("SourceCodePro-Bold", size: 16))
                                .foregroundStyle(Color.fText)
                                .padding(.trailing, 1)
                        }
                    }
                }
            }
            .onAppear {
                timerViewModel.onTimerComplete = {
                    if timerViewModel.isWorkSession {
                        withAnimation {
                            kryptonsEarned += 1
                        }
                    } else {
                        isGame = false
                    }
                }
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
            .fullScreenCover(isPresented: $isGame) {
                GameView()
            }
        }
    }
}

#Preview {
    PomodoroTimerView()
}
