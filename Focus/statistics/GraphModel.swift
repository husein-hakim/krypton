//
//  GraphModel.swift
//  Focus
//
//  Created by Husein Hakim on 16/01/25.
//

import Foundation

enum GraphOptions: String, CaseIterable, Identifiable {
    case duration = "Duration"
    case breaks = "Break"
    
    var id: Self {self}
}

enum GraphType: String, CaseIterable, Identifiable {
    case bar = "chart.bar.fill"
    case line = "chart.xyaxis.line"
    
    var id: Self {self}
}

struct GraphData: Identifiable, Hashable {
    let id = UUID()
    let day: String
    let duration: Int
}

struct BreakGraphData: Identifiable, Hashable {
    let id = UUID()
    let day: String
    let duration: Int
    let count: Int
}
