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
    @Published var userProfile: [User] = []
    
    init() {
        let supabaseURL = Secrets.SUPABASE_URL
        let supabase_API_KEY = Secrets.SUPABASE_API_KEY
        
        self.client = SupabaseClient(supabaseURL: URL(string: supabaseURL)!, supabaseKey: supabase_API_KEY)
    }
    
    func registerNewUser(email: String, password: String, username: String, profile: String) async throws {
        do {
            let response = try await client.auth.signUp(email: email, password: password)
            
            guard let session = response.session else {
                print("no session when registering user")
                throw NSError()
            }
            
            let userData = try await User(id: client.auth.session.user.id, email: email, password: password, username: username, profile: profile)
            
            let insertResponse = try await client.from("Users").insert(userData).execute()
            
            print("User signed up with: \(try await client.auth.session.user.id)")
        } catch {
            print("Error: \(error.localizedDescription)")
            throw error
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
    
//    func getInitialProfile() async {
//        var profiles: [User] = []
//        do {
//            let currentUser = try await client.auth.session.user.id
//            profiles = try await client.from("Users").select().eq("id", value: currentUser).execute().value
//            print(profiles)
//            userProfile = profiles
//        } catch {
//            print("error occured:\(error.localizedDescription)")
//        }
//    }
    
    func getInitialProfile(completion: @escaping([User]) -> Void) async throws {
        var profiles: [User] = []
        do {
            let currentUser = try await client.auth.session.user.id
            profiles = try await client.from("Users").select().eq("id", value: currentUser).execute().value
            userProfile = profiles
            completion(profiles)
        } catch {
            print("error occured:\(error.localizedDescription)")
        }
    }
    
    func getProfile() async throws {
        do {
            let currentUser = try await client.auth.session.user.id
            userProfile = try await client.from("Users").select().eq("id", value: currentUser).execute().value
        }
    }
    
    func checkIfLoggedIn() async throws -> Bool {
        do {
            if try await client.auth.session.user != nil {
                return true
            } else {
                return false
            }
        } catch {
            return false
        }
    }
}
