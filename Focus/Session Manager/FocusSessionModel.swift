//
//  FocusSessionModel.swift
//  Focus
//
//  Created by Husein Hakim on 08/01/25.
//

import Foundation

struct FocusSessionManager: Decodable, Encodable, Hashable, Identifiable {
    let id = UUID()
    let user_id: UUID
    let duration: Int
    let kryptons_earned: Int
    let timestamp: Date
    let breaks_taken: Int
    let breaks_duration: Int
}
