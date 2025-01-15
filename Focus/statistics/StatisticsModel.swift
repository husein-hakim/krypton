//
//  StatisticsModel.swift
//  Focus
//
//  Created by Husein Hakim on 15/01/25.
//

import Foundation
import Supabase

class StatisticsModel: ObservableObject {
    private let client: SupabaseClient
    
    @Published var sessions: [FocusSessionManager] = []
    
    init() {
        let supabaseURL = Secrets.SUPABASE_URL
        let supabase_API_KEY = Secrets.SUPABASE_API_KEY
        
        self.client = SupabaseClient(supabaseURL: URL(string: supabaseURL)!, supabaseKey: supabase_API_KEY)
    }
    
    func fetchSessions() async throws {
        var fetchedSessions: [FocusSessionManager] = []
        do {
            let currentUser = try await client.auth.session.user.id
            fetchedSessions = try await client.from("FocusSessions").select().eq("user_id", value: currentUser).execute().value
            sessions = fetchedSessions
            print(fetchedSessions)
        } catch {
            print("error fetching sessions: \(error.localizedDescription)")
        }
    }
    
    func getWeeklySessions() -> [FocusSessionManager] {
        var filteredSessions: [FocusSessionManager] = []
        for session in sessions {
            if session.timestamp.timeIntervalSinceNow < 7 * 24 * 60 * 60 {
                filteredSessions.append(session)
            }
        }
        return filteredSessions
    }
}
