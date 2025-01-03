//
//  ContentView.swift
//  Focus
//
//  Created by Husein Hakim on 26/12/24.
//

import SwiftUI

struct ContentView: View {
    enum Mode: String, CaseIterable, Identifiable {
        case timer = "timer.circle.fill"
        case pomodoro = "hourglass"
        
        var id: Self {self}
    }
    @State var mode: Mode = .timer
    
    var body: some View {
        ZStack {
            Color.fPrimary.ignoresSafeArea()
            
            VStack {
                HStack {
                    Button {

                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(Color.white)
                    }
                    .padding()
                    
                    Spacer()
                    
                    Picker("mode selection", selection: $mode) {
                        ForEach(Mode.allCases, id: \.self) { mode in
                            Button {
                                
                            } label: {
                                Image(systemName: mode.rawValue)
                                    .foregroundStyle(Color.fPrimary)
                            }
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 100)
                    .foregroundStyle(Color.black)
                    
                    Spacer()
                    
                    Image(systemName: "bitcoinsign")
                        .padding()
                }
                
                Spacer()
                
                if mode == .timer {
                    TimerView()
                } else {
                    PomodoroTimerView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
