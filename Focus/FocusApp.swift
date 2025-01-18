//
//  FocusApp.swift
//  Focus
//
//  Created by Husein Hakim on 15/12/24.
//

import SwiftUI
import DeviceActivity

@main
struct FocusApp: App {
    @StateObject var authModel = AuthModel()
    @StateObject var appState = AppState()
    @State private var showSplash = true
    @State private var opacity = 1.0
    
    var body: some Scene {
        WindowGroup {
            //GameView()
            //ContentView()
            Group {
                switch appState.authState {
                case .checking:
//                    SplashScreen()
//                        .transition(.opacity)
                    
                    Color.fPrimary.ignoresSafeArea()
                    
                case .loggedIn:
//                    if !showSplash {
                        TabBarView()
                            .environmentObject(authModel)
                            //.opacity(showSplash ? 0 : 1)
                            //.animation(.easeIn(duration: 0.3), value: showSplash)
//                    }
                    
//                    if showSplash {
//                        SplashScreen()
//                            .transition(.opacity)
//                            .opacity(opacity)
//                            .animation(.easeOut(duration: 0.3), value: opacity)
//                    }
                    
                    //GameView()
                    
                case .loggedOut:
                    LoginView()
                }
            }
            .onAppear {
                appState.checkAuthStatus()
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
//                    opacity = 0
//                }
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
//                    withAnimation {
//                        showSplash = false
//                    }
//                }
            }
        }
    }
}
