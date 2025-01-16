//
//  StatisticsView.swift
//  Focus
//
//  Created by Husein Hakim on 15/01/25.
//

import SwiftUI
import Charts
import Foundation

struct StatisticsView: View {
    @StateObject var statisticsModel = StatisticsModel()
    @State var filteredSessions: [FocusSessionManager] = []
    @State var isLoading: Bool = false
    @State var weeklyGraphData: [GraphData] = []
    @State var monthlyGraphData: [(day: String, duration: Int)] = []
    @State var breakGraphData: [BreakGraphData] = []
    @State var graphOptions: GraphOptions = .duration
    @State var graphType: GraphType = .bar
    
    var body: some View {
        ZStack {
            Color.fPrimary.ignoresSafeArea()
            
            if isLoading {
                ScrollView {
                    Text("Statistics")
                        .font(.custom("SourceCodePro-Bold", size: 30))
                        .foregroundStyle(Color.fText)
                    
                    Picker("Options", selection: $graphOptions) {
                        ForEach(GraphOptions.allCases) { option in
                            Text(option.rawValue)
                                .font(.custom("SourceCodePro", size: 13))
                                .foregroundStyle(Color.fText)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 300, height: 100)
                    
                    if graphOptions == .duration {
                        if graphType == .bar {
                            DurationBarGraph(graphData: weeklyGraphData)
                        } else {
                            DurationLineGraph(graphData: weeklyGraphData)
                        }
                        
                        HStack {
                            Spacer()
                            
                            Picker("type", selection: $graphType) {
                                ForEach(GraphType.allCases) { type in
                                    Image(systemName: type.rawValue)
                                }
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 100, height: 100)
                        }
                    } else {
                        VStack {
                            HStack {
                                Text("Break Duration")
                                    .font(.custom("SourceCodePro", size: 25))
                                    .foregroundStyle(Color.fText)
                                    .padding()
                                
                                Spacer()
                            }
                            
                            if graphType == .bar {
                                DurationBreakBarGraph(breakData: breakGraphData)
                            } else {
                                DurationBreakLineGraph(graphData: breakGraphData)
                            }
                        }
                        
                        HStack {
                            Spacer()
                            
                            Picker("type", selection: $graphType) {
                                ForEach(GraphType.allCases) { type in
                                    Image(systemName: type.rawValue)
                                }
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 100, height: 100)
                        }
                        
                        VStack {
                            HStack {
                                Text("No of Breaks")
                                    .font(.custom("SourceCodePro", size: 25))
                                    .foregroundStyle(Color.fText)
                                    .padding()
                                
                                Spacer()
                            }
                            
                            BreakCountBarGraph(breakData: breakGraphData)
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
                if statisticsModel.sessions.isEmpty {
                    try await statisticsModel.fetchSessions()
                }
                weeklyGraphData = prepareGraphData(sessions: statisticsModel.sessions)
                monthlyGraphData = prepareMonthlyGraphData(sessions: statisticsModel.sessions)
                breakGraphData = prepareBreakGraphData(breaks: statisticsModel.sessions)
                
                isLoading = true
            }
        }
    }
}

struct DurationBarGraph: View {
    let graphData: [GraphData]
    var body: some View {
        Chart(graphData, id: \.day) { data in
            BarMark(
                x: .value("Day", data.day),
                y: .value("Duration", data.duration)
            )
            .foregroundStyle(Color.fSecondary)
        }
        .chartXAxis {
            AxisMarks { value in
                if let day = value.as(String.self) {
                    AxisValueLabel(day)
                        .font(.custom("SourceCodePro", size: 15))
                        .foregroundStyle(Color.fText)
                }
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisValueLabel("\(value.as(Int.self) ?? 0) min")
                    .font(.custom("SourceCodePro", size: 15))
                    .foregroundStyle(Color.fText)
            }
        }
        .frame(height: 300)
        .padding()
    }
}

struct DurationLineGraph: View {
    let graphData: [GraphData]
    
    var body: some View {
        Chart {
            ForEach(graphData, id: \.self) { data in
                LineMark(x: .value("Day", data.day),
                         y: .value("Duration", data.duration)
                )
                .symbol(Circle())
                .foregroundStyle(Color.fSecondary)
            }
        }
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel()
                    .font(.custom("SourceCodePro", size: 15))
                    .foregroundStyle(Color.fText)
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisValueLabel("\(value.as(Int.self) ?? 0) min")
                    .font(.custom("SourceCodePro", size: 15))
                    .foregroundStyle(Color.fText)
            }
        }
        .frame(height: 300)
        .padding()
    }
}

struct DurationBreakBarGraph: View {
    let breakData: [BreakGraphData]

    var body: some View {
        Chart {
            ForEach(breakData) { data in
                BarMark(
                    x: .value("Day", data.day),
                    y: .value("Duration", data.duration)
                )
                .foregroundStyle(Color.fSecondary)
            }
        }
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel()
                    .font(.custom("SourceCodePro", size: 15))
                    .foregroundStyle(Color.fText)
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisValueLabel("\(value.as(Int.self) ?? 0) min")
                    .font(.custom("SourceCodePro", size: 15))
                    .foregroundStyle(Color.fText)
            }
        }
        .frame(height: 300)
        .padding()
    }
}

struct DurationBreakLineGraph: View {
    let graphData: [BreakGraphData]
    
    var body: some View {
        Chart {
            ForEach(graphData, id: \.self) { data in
                LineMark(x: .value("Day", data.day),
                         y: .value("Duration", data.duration)
                )
                .symbol(Circle())
                .foregroundStyle(Color.fSecondary)
            }
        }
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel()
                    .font(.custom("SourceCodePro", size: 15))
                    .foregroundStyle(Color.fText)
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisValueLabel("\(value.as(Int.self) ?? 0) min")
                    .font(.custom("SourceCodePro", size: 15))
                    .foregroundStyle(Color.fText)
            }
        }
        .frame(height: 300)
        .padding()
    }
}

struct BreakCountBarGraph: View {
    let breakData: [BreakGraphData]
    
    var body: some View {
        Chart {
            ForEach(breakData) { data in
                BarMark(
                    x: .value("Day", data.day),
                    y: .value("No of Breaks", data.count)
                )
                .foregroundStyle(Color.fSecondary)
            }
        }
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel()
                    .font(.custom("SourceCodePro", size: 15))
                    .foregroundStyle(Color.fText)
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisValueLabel("\(value.as(Int.self) ?? 0)")
                    .font(.custom("SourceCodePro", size: 15))
                    .foregroundStyle(Color.fText)
            }
        }
        .frame(height: 300)
        .padding()
    }
}
