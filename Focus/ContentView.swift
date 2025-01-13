//
//  ContentView.swift
//  Focus
//
//  Created by Husein Hakim on 26/12/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authModel: AuthModel
    enum Mode: String, CaseIterable, Identifiable {
        case timer = "timer.circle.fill"
        case pomodoro = "hourglass"
        
        var id: Self {self}
    }
    @State var mode: Mode = .timer
    @State var isLoading: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.fPrimary.ignoresSafeArea()
                
                if isLoading {
                    VStack {
                        HStack {
                            Spacer()
                            
                            Picker("mode selection", selection: $mode) {
                                ForEach(Mode.allCases, id: \.self) { currentMode in
                                    Button {
                                        mode = currentMode
                                    } label: {
                                        Image(systemName: currentMode.rawValue)
                                            .foregroundStyle(Color.fPrimary)
                                    }
                                }
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 100)
                            .foregroundStyle(Color.black)
                            
                            Spacer()
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
            .onAppear {
                if authModel.userProfile.isEmpty {
                    Task {
                        try await authModel.getProfile()
                        isLoading = true
                    }
                } else {
                    isLoading = true
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if isLoading {
                        Image(authModel.userProfile[0].profile)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .scaledToFit()
                            .clipShape(Circle())
                            .padding()
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    if isLoading {
                        Text(authModel.userProfile[0].username)
                            .font(.custom("SourceCodePro-Bold", size: 20))
                            .foregroundStyle(Color.fText)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
