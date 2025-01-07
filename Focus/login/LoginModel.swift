//
//  LoginModel.swift
//  Focus
//
//  Created by Husein Hakim on 07/01/25.
//

import Foundation
import Supabase

class AuthModel: ObservableObject {
    private let client: SupabaseClient
    
    @Published var isLoggedIn = false
    @Published var errorMessage: String? = nil
    
    init() {
        let supabaseURL = Secrets.SUPABASE_URL
        let supabase_API_KEY = Secrets.SUPABASE_API_KEY
        
        self.client = SupabaseClient(supabaseURL: URL(string: supabaseURL)!, supabaseKey: supabase_API_KEY)
    }
    
    func registerNewUser(email: String, password: String) async throws {
        let response = try await client.auth.signUp(email: email, password: password)
        guard let session = response.session else {
            print("no session when registering user")
            throw NSError()
        }
    }
    
    func signInWithEmail(email: String, password: String) async throws {
        let response = try await client.auth.signIn(email: email, password: password)
    }
    
    func isUserAuthenticated() async {
        do {
            // Attempt to fetch the session.
            let session = try await client.auth.session
            
            // Check if the session's user exists
            if session.user != nil {
                DispatchQueue.main.async {
                    self.isLoggedIn = true
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "No active user found."
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Error: \(error.localizedDescription)"
            }
        }
    }

    func signOut() async throws {
        try await client.auth.signOut()
        DispatchQueue.main.async {
            self.isLoggedIn = false
        }
    }
}
