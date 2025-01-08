//
//  AppState.swift
//  Focus
//
//  Created by Husein Hakim on 08/01/25.
//

import Foundation

enum AuthState {
    case checking
    case loggedIn
    case loggedOut
}

class AppState: ObservableObject {
    @Published var authState: AuthState = .checking
    private let authModel = AuthModel()
    
    func checkAuthStatus() {
        Task {
            do {
                let isAuthenticated = try await authModel.checkIfLoggedIn()
                DispatchQueue.main.async {
                    self.authState = isAuthenticated ? .loggedIn : .loggedOut
                }
            } catch {
                DispatchQueue.main.async {
                    self.authState = .loggedOut
                }
            }
        }
    }
}
