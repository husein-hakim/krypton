//
//  UserModel.swift
//  Focus
//
//  Created by Husein Hakim on 07/01/25.
//

import Foundation

struct User: Encodable {
    let id: UUID
    let email: String
    let password: String
    let username: String
    let profile: String
}
