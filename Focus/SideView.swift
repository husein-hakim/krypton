//
//  SideView.swift
//  Focus
//
//  Created by Husein Hakim on 09/01/25.
//

import SwiftUI

struct SideView: View {
    @Binding var isMenuOpen: Bool
    let userProfile: User
    @EnvironmentObject var authModel: AuthModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Profile Section
            VStack(alignment: .leading) {
                Image(userProfile.profile)
                    .resizable()
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
                Text(userProfile.username ?? "User")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(.top, 30)
            
            // Menu Items
            ForEach(MenuItems.allCases, id: \.self) { item in
                Button(action: {
                    // Handle menu item action
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isMenuOpen = false
                    }
                }) {
                    HStack {
                        Image(systemName: item.icon)
                            .frame(width: 24)
                        Text(item.title)
                        Spacer()
                    }
                    .foregroundColor(.white)
                }
                .padding(.vertical, 8)
            }
            
            Spacer()
            
            Divider()
                .background(Color.white.opacity(0.5))
            
            Button(action: {
                
            }) {
                HStack {
                    Image(systemName: "gear")
                        .frame(width: 24)
                    Text("Settings")
                    Spacer()
                }
                .foregroundColor(.white)
            }
            .padding(.vertical, 8)
            
            Button(action: {
                Task {
                    try await authModel.signOut()
                }
            }) {
                HStack {
                    Image(systemName: "gear")
                        .frame(width: 24)
                    Text("Sign out")
                    Spacer()
                }
                .foregroundColor(.white)
            }
            .padding(.vertical, 8)
        }
        .padding()
        .frame(maxHeight: .infinity)
        .background(Color.fSecondary)
    }
}

enum MenuItems: CaseIterable {
    case statistics, history, profile
    
    var title: String {
        switch self {
        case .statistics: return "Statistics"
        case .history: return "History"
        case .profile: return "Profile"
        }
    }
    
    var icon: String {
        switch self {
        case .statistics: return "chart.bar.fill"
        case .history: return "clock.fill"
        case .profile: return "person.fill"
        }
    }
}
