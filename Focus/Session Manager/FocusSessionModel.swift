//
//  FocusSessionModel.swift
//  Focus
//
//  Created by Husein Hakim on 08/01/25.
//

import Foundation

struct FocusSessionManager: Decodable, Encodable {
    let user_id: UUID
    let duration: Int
    let kryptons_earned: Int
}
