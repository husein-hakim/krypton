//
//  TabBarView.swift
//  Focus
//
//  Created by Husein Hakim on 13/01/25.
//

import SwiftUI

struct TabBarView: View {
    @EnvironmentObject var authModel: AuthModel
    
    var body: some View {
        TabView {
            ContentView()
                .environmentObject(authModel)
                .tabItem {
                    Image(systemName: "house")
                }
            
            Text("Stats")
                .tabItem {
                    Image(systemName: "house")
                }
        }
    }
}

#Preview {
    TabBarView()
}
