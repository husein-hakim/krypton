//
//  SplashScreen.swift
//  Focus
//
//  Created by Husein Hakim on 18/01/25.
//

import SwiftUI

struct SplashScreen: View {
    @State private var bounce = false
    
    var body: some View {
        ZStack {
            Color.fPrimary.ignoresSafeArea()
            
            VStack {
                Image("krypton")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .offset(y: bounce ? -10 : 10) // Bounce effect
                    .animation(
                        Animation.easeInOut(duration: 1.2)
                            .repeatForever(autoreverses: true),
                        value: bounce
                    )
            }
        }
        .onAppear {
            bounce = true
        }
    }
}

#Preview {
    SplashScreen()
}
