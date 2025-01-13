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
    var body: some Scene {
        WindowGroup {
            //GameView()
            //ContentView()
            Group {
                switch appState.authState {
                case .checking:
                    Text("checking")
                    
                case .loggedIn:
                    TabBarView()
                        .environmentObject(authModel)
                    
//                    GameView()
                    
                case .loggedOut:
                    LoginView()
                }
            }
            .onAppear {
                appState.checkAuthStatus()
            }
        }
    }
}
