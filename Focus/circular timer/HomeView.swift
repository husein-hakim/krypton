//
//  HomeView.swift
//  Focus
//
//  Created by Husein Hakim on 18/12/24.
//

import SwiftUI

struct HomeView: View {
    let minutes: Double
    @Binding var isFocus: Bool
    @StateObject private var focusTimerViewModel = CircularTimerViewModel(totalMinutes: 1)
    @StateObject var breakTimerViewModel = BreakTimerViewModel(totalMinutes: 5)
    @State var isBreak: Bool = false
    @State var soundMenu: Bool = false
    @State var playing: Bool = false
    @State var isGame: Bool = false
    @State var selectedKrypton: String
    @State var breakCounter: Int = 0
    @State var breakDuration: Int = 0
    @State var focusProgress: Double = 0.0
    
    @StateObject private var audioPlayer = AudioPlayer()
    @StateObject var focusSessionManager = FocusSessionsManager()
    
    @Environment(\.scenePhase) var scenePhase
    
    @State var backgroundMusic: BackgroundMusic = .forest
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.fPrimary.ignoresSafeArea()
                
                VStack {
                    CircularTimerView(viewModel: isBreak ? breakTimerViewModel : focusTimerViewModel, isFocus: $isFocus, selectedKrypton: selectedKrypton, focusProgress: $focusProgress, isBreak: $isBreak)
                    
                    if isBreak {
                        Button {
                            breakDuration += breakTimerViewModel.secondsUsed
                            withAnimation {
                                isBreak = false
                            }
                            focusTimerViewModel.startTimer()
                            breakTimerViewModel.stopTimer()
                            breakTimerViewModel.isCooldownActive = true
                            breakTimerViewModel.startCooldown(cooldownMinutes: 5)
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(Color.green)
                                    .frame(width: 100, height: 50)
                                
                                Text("Resume Focus")
                                    .font(.custom("SourceCodePro-Bold", size: 16))
                                    .foregroundStyle(Color.black)
                            }
                        }
                        .frame(width: 75, height: 50)
                        .padding()
                        
                        Button {
                            isGame = true
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(Color.fSecondary)
                                    .frame(width: 100, height: 50)
                                
                                Text("Play")
                                    .font(.custom("SourceCodePro-Bold", size: 16))
                                    .foregroundStyle(Color.black)
                            }
                        }
                        .frame(width: 75, height: 50)
                        .padding()
                    } else {
                        Button {
                            if !breakTimerViewModel.isCooldownActive {
                                breakCounter += 1
                                print(breakCounter)
                                withAnimation {
                                    isBreak = true
                                }
                                focusProgress = focusTimerViewModel.progress
                                focusTimerViewModel.stopTimer()
                                breakTimerViewModel.startTimer()
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(breakTimerViewModel.isCooldownActive ? .gray : .green)
                                    .frame(width: 100, height: 50)
                                
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(Color.green)
                                    .frame(width: 100, height: 50)
                                    .mask {
                                        GeometryReader { geometry in
                                            Rectangle()
                                                .frame(width: geometry.size.width * CGFloat(breakTimerViewModel.cooldownProgress))
                                                .animation(.linear(duration: 1), value: breakTimerViewModel.cooldownProgress)
                                        }
                                    }
                                
                                Text("Break")
                                    .font(.custom("SourceCodePro-Bold", size: 16))
                                    .foregroundStyle(Color.black)
                            }
                        }
                        .frame(width: 75, height: 50)
                        .padding()
                        .disabled(breakTimerViewModel.isCooldownActive)
                    }
                    
                    Button {
                        isFocus = false
                        audioPlayer.stopAllSounds()
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
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
//                        Button {
//                            if playing {
//                                audioPlayer.stopAllSounds()
//                            } else {
//                                audioPlayer.playSound(fileName: "forest", fileType: "wav")
//                            }
//                            
//                            playing.toggle()
//                        } label: {
//                            Image(systemName: playing ? "headphones" : "headphones.slash")
//                                .foregroundStyle(Color.black)
//                        }
                        
                        Menu {
                            ForEach(BackgroundMusic.allCases) { music in
                                Button {
                                    audioPlayer.stopAllSounds()
                                    audioPlayer.playSound(fileName: music.rawValue, fileType: "wav")
                                    playing = true
                                } label: {
                                    Text(music.rawValue)
                                        .font(.custom("SourceCodePro-Regular", size: 18))
                                }
                            }
                            
                            Button {
                                audioPlayer.stopAllSounds()
                                playing = false
                            } label: {
                                Text("Stop Playing")
                            }

                        } label: {
                            Image(systemName: playing ? "headphones" : "headphones.slash")
                                .foregroundStyle(Color.black)
                        }

                    }
                }
            }
            .onAppear {
                breakTimerViewModel.isCooldownActive = true
                breakTimerViewModel.startCooldown(cooldownMinutes: 5)
                breakTimerViewModel.onTimerComplete = {
                    isGame = false
                    focusTimerViewModel.startTimer()
                    breakTimerViewModel.isCooldownActive = true
                    breakTimerViewModel.startCooldown(cooldownMinutes: 5)
                    withAnimation {
                        isBreak = false
                    }
                }
                focusTimerViewModel.totalSeconds = Int(minutes * 60)
                UIApplication.shared.isIdleTimerDisabled = true
                focusTimerViewModel.onTimerComplete = {
                    Task {
                        do {
                            try await focusSessionManager.createFocusSession(duration: Int(minutes), kryptons_earned: Int(floor(minutes/15)), breaks_taken: breakCounter, break_duration: breakDuration)
                            isFocus = false
                        } catch {
                            print("error initializing focus session upload")
                        }
                    }
                }
            }
            .onChange(of: scenePhase) { newPhase in
                switch newPhase {
                case .background:
                    focusTimerViewModel.stopTimer()
                    isFocus = false
                    
                case .active:
                    focusTimerViewModel.startTimer()
                    
                default:
                    break
                }
            }
        }
        .fullScreenCover(isPresented: $isGame) {
            GameView()
        }
    }
}

struct CircularTimerView: View {
    @ObservedObject var viewModel: CircularTimerViewModel
    @Binding var isFocus: Bool
    @State var selectedKrypton: String
    @Binding var focusProgress: Double
    @Binding var isBreak: Bool
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                    .frame(width: 250, height: 250)

                Circle()
                    .trim(from: 0.0, to: CGFloat(viewModel.progress))
                    .stroke(Color.fSecondary, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 250, height: 250)
                
                ZStack {
                    Image(selectedKrypton)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .saturation(0)
                    
                    Image(selectedKrypton)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .mask(
                            VStack {
                                Spacer()
                                
                                GeometryReader { geometry in
                                    Rectangle()
                                        .frame(height: !isBreak ? CGFloat(viewModel.progress) * geometry.size.height : focusProgress * geometry.size.height)
                                        .animation(.linear(duration: TimeInterval(viewModel.totalSeconds)), value: (viewModel.progress))
                                }
                            }
                        )
                }
            }
            
            VStack {
                Text("\(viewModel.minutesLeft) min")
                    .font(.custom("SourceCodePro-Bold", size: 30))
                    .foregroundColor(Color.fText)
                
                Text("\(viewModel.secondsLeft) sec")
                    .font(.custom("SourceCodePro-Bold", size: 25))
                    .foregroundColor(Color.fTertiary)
            }
        }
        .onAppear {
            viewModel.startTimer()
        }
        .onChange(of: isFocus) { oldValue, newValue in
            print(newValue)
            if !newValue {
                viewModel.stopTimer()
            }
        }
    }
}
