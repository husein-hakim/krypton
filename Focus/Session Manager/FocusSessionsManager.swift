//
//  FocusSessionsManager.swift
//  Focus
//
//  Created by Husein Hakim on 08/01/25.
//

import Foundation
import Supabase

class FocusSessionsManager: ObservableObject {
    private let client: SupabaseClient
    
    init() {
        let supabaseURL = Secrets.SUPABASE_URL
        let supabase_API_KEY = Secrets.SUPABASE_API_KEY
        
        self.client = SupabaseClient(supabaseURL: URL(string: supabaseURL)!, supabaseKey: supabase_API_KEY)
    }
    
    func createFocusSession(duration: Int, kryptons_earned: Int) async throws {
        do {
            let currentUser = try await client.auth.session.user.id
            let focusData = FocusSessionManager(user_id: currentUser, duration: duration, kryptons_earned: kryptons_earned)
            let insertResult = try await client.from("FocusSessions").insert(focusData).execute()
        } catch {
            print("error uploading focus session: \(error.localizedDescription)")
        }
    }
}
