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
    @StateObject private var focusTimerViewModel = CircularTimerViewModel(totalMinutes: 0)
    @StateObject var breakTimerViewModel = BreakTimerViewModel(totalMinutes: 5)
    @State var isBreak: Bool = false
    @State var soundMenu: Bool = false
    @State var playing: Bool = false
    
    @StateObject private var audioPlayer = AudioPlayer()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.fPrimary.ignoresSafeArea()
                
                VStack {
                    CircularTimerView(viewModel: isBreak ? breakTimerViewModel : focusTimerViewModel, isFocus: $isFocus)
                    
                    if isBreak {
                        Button {
                            isBreak = false
                            focusTimerViewModel.startTimer()
                            breakTimerViewModel.stopTimer()
                            breakTimerViewModel.isCooldownActive = true
                            breakTimerViewModel.startCooldown(cooldownMinutes: 15)
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(Color.green)
                                    .frame(width: 100, height: 50)
                                
                                Text("Resume Focus")
                                    .bold()
                                    .font(.system(size: 16))
                                    .foregroundStyle(Color.black)
                            }
                        }
                        .frame(width: 75, height: 50)
                        .padding()
                    } else {
                        Button {
                            if !breakTimerViewModel.isCooldownActive {
                                isBreak = true
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
                                    .bold()
                                    .font(.system(size: 16))
                                    .foregroundStyle(Color.black)
                            }
                        }
                        .frame(width: 75, height: 50)
                        .padding()
                        .disabled(breakTimerViewModel.isCooldownActive)
                    }
                    
                    Button {
                        isFocus = false
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color.red)
                                .frame(width: 100, height: 50)
                            
                            Text("Give Up")
                                .bold()
                                .font(.system(size: 16))
                                .foregroundStyle(Color.black)
                        }
                    }
                    .frame(width: 75, height: 50)
                    .padding()
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            if playing {
                                audioPlayer.stopSound()
                            } else {
                                audioPlayer.playSound(fileName: "forest", fileType: "wav")
                            }
                            
                            playing.toggle()
                        } label: {
                            Image(systemName: playing ? "headphones" : "headphones.slash")
                                .foregroundStyle(Color.black)
                        }

                    }
                }
            }
            .onAppear {
                breakTimerViewModel.isCooldownActive = true
                breakTimerViewModel.startCooldown(cooldownMinutes: 15)
                focusTimerViewModel.totalSeconds = Int(minutes * 60)
            }
        }
    }
}

struct CircularTimerView: View {
    @ObservedObject var viewModel: CircularTimerViewModel
    @Binding var isFocus: Bool
    
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
                    Image("krypton")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .saturation(0)
                    
                    Image("krypton")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .mask(
                            Rectangle()
                                .frame(height: viewModel.progress * 100)
                                .animation(.linear(duration: TimeInterval(viewModel.totalSeconds)), value: viewModel.progress)
                        )
                }
            }
            
            VStack {
                Text("\(viewModel.minutesLeft) min")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.fText)
                
                Text("\(viewModel.secondsLeft) sec")
                    .font(.title2)
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

struct CooldownDisplayView: View {
    @ObservedObject var viewModel: BreakTimerViewModel

    var body: some View {
        VStack {
            Text("Cooldown Active")
                .font(.largeTitle)
                .foregroundColor(.white)

            Text("Time Remaining: \(viewModel.cooldownSecondsLeft / 60) min \(viewModel.cooldownSecondsLeft % 60) sec")
                .font(.title2)
                .foregroundColor(.gray)

            Text("Please wait before starting a new break.")
                .foregroundColor(.white)
                .padding()
        }
    }
}
