//
//  TabBarView.swift
//  Focus
//
//  Created by Husein Hakim on 13/01/25.
//

import SwiftUI

struct TabBarView: View {
    @EnvironmentObject var authModel: AuthModel
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.fTertiary
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.fSecondary
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.yellow]
        
        UITabBar.appearance().standardAppearance = appearance
        
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    var body: some View {
        TabView {
            ContentView()
                .environmentObject(authModel)
                .tabItem {
                    Image(systemName: "house")
                }
            
            StatisticsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                }
        }
        .background(Color.red)
    }
}

#Preview {
    TabBarView()
}
