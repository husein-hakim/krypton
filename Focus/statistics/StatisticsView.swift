//
//  StatisticsView.swift
//  Focus
//
//  Created by Husein Hakim on 15/01/25.
//

import SwiftUI
import Charts

struct StatisticsView: View {
    @StateObject var statisticsModel = StatisticsModel()
    
    var body: some View {
        ZStack {
            Color.fPrimary.ignoresSafeArea()
            
            VStack {
                Chart {
                    ForEach(statisticsModel.sessions) { sessions in
                        BarMark(x: .value("Date", sessions.timestamp, unit: .day),
                                y: .value("Duration (minutes)", sessions.duration))
                        .foregroundStyle(Color.fSecondary.gradient)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisValueLabel()
                    }
                }
            }
            .frame(height: 300)
        }
        .onAppear {
            Task {
                try await statisticsModel.fetchSessions()
                print(statisticsModel.getWeeklySessions())
            }
        }
    }
}
