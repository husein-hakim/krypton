//
//  BackgroundMusicModel.swift
//  Focus
//
//  Created by Husein Hakim on 16/01/25.
//

import Foundation

enum BackgroundMusic: String, CaseIterable, Identifiable {
    case forest = "forest"
    case crickets = "crickets"
    
    var id: Self {self}
}
