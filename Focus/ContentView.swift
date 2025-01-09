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
    @State var isMenuOpen: Bool = false
    
    @State private var menuOffset: CGFloat = 0
    private let menuWidth: CGFloat = 300
    
    var body: some View {
        ZStack {
            Color.fPrimary.ignoresSafeArea()
            
            if isLoading {
                VStack {
                    HStack {
                        Button {
                            withAnimation {
                                isMenuOpen.toggle()
                            }
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
                        
                        Image(authModel.userProfile[0].profile)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .scaledToFit()
                            .clipShape(Circle())
                            .padding()
                    }
                    
                    Spacer()
                    
                    if mode == .timer {
                        TimerView()
                    } else {
                        PomodoroTimerView()
                    }
                }
                .disabled(isMenuOpen)
                .offset(x: isMenuOpen ? 300 : 0)
                .opacity(isMenuOpen ? 0.3 : 1.0)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            if gesture.translation.width > 0 { // Only allow right swipe
                                menuOffset = gesture.translation.width
                            }
                        }
                        .onEnded { gesture in
                            withAnimation(.spring(response: 0.4, dampingFraction: 1.0)) {
                                if gesture.translation.width > menuWidth/4 {
                                    menuOffset = menuWidth
                                    isMenuOpen = true
                                } else {
                                    menuOffset = 0
                                    isMenuOpen = false
                                }
                            }
                        }
                )
                
                if isMenuOpen {
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            SideView(isMenuOpen: $isMenuOpen, userProfile: authModel.userProfile[0])
                                .frame(width: 300)
                                .offset(x: isMenuOpen ? 0 : -300)
                            
                            Spacer()
                        }
                    }
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isMenuOpen)
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
    }
}

#Preview {
    ContentView()
}
