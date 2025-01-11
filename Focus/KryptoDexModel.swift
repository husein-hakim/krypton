//
//  KryptoDexModel.swift
//  Focus
//
//  Created by Husein Hakim on 11/01/25.
//

import Foundation
import Supabase

class KryptoDexModel: ObservableObject {
    private let client: SupabaseClient
    
    @Published var kryptoDex: [String] = []
    
    init() {
        let supabaseURL = Secrets.SUPABASE_URL
        let supabase_API_KEY = Secrets.SUPABASE_API_KEY
        
        self.client = SupabaseClient(supabaseURL: URL(string: supabaseURL)!, supabaseKey: supabase_API_KEY)
    }
    
    func fetchKryptoDex() async throws {
        do {
            let currentUser = try await client.auth.session.user.id
            let kryptoDexData: [KrptoDex] = try await client.from("KryptoDex").select().eq("id", value: currentUser).execute().value
            kryptoDex = kryptoDexData[0].kryptons.components(separatedBy: ",")
            print(kryptoDex)
        } catch {
            print("error occured: \(error.localizedDescription)")
        }
    }
    
    func updateKryptoDex(krypto: String) async throws {
        do {
            let currentUser = try await client.auth.session.user.id
            kryptoDex.append(krypto)
            try await client.from("KryptoDex").update(["kryptons": kryptoDex.joined(separator: ",")]).eq("id", value: currentUser).execute()
        } catch {
            print("error updating kryptodex: \(error.localizedDescription)")
        }
    }
    
    func createKryptoDex() async throws {
        do {
            let currentUser = try await client.auth.session.user.id
            try await client.from("KryptoDex").insert(KrptoDex(id: currentUser, kryptons: "")).execute()
        } catch {
            print("error updating kryptodex: \(error.localizedDescription)")
        }
    }
}

struct KrptoDex: Encodable, Decodable, Identifiable {
    let id: UUID
    let kryptons: String
}
