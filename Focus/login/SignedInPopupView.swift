//
//  SignedInPopupView.swift
//  Focus
//
//  Created by Husein Hakim on 07/01/25.
//

import SwiftUI

struct SignedInPopupView: View {
    @StateObject var authModel = AuthModel()
    @State var receivedProfile: Bool = false
    @State var userprofiles: [User] = []
    @State var opacity: Double = 0.0
    @State var start: Bool = false
    var body: some View {
        ZStack {
            Color.fPrimary.ignoresSafeArea()
            
            VStack {
                if receivedProfile {
                    Image(userprofiles[0].profile)
                        .resizable()
                        .frame(width: 100, height: 100)
                        .scaledToFit()
                        .clipShape(Circle())
                        .opacity(opacity)
                        .animation(.easeIn(duration: 2), value: opacity)
                        .onAppear {
                            opacity = 1
                        }
                    
                    Text(userprofiles[0].username)
                        .font(.custom("SourceCodePro-Bold", size: 25))
                        .foregroundStyle(Color.fText)
                        .opacity(opacity)
                        .animation(.easeIn(duration: 2), value: opacity)
                    
                    Button {
                        start = true
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 100, height: 50)
                                .foregroundStyle(Color.fSecondary)
                            
                            Text("Lets Go!")
                                .font(.custom("SourceCodePro-Bold", size: 20))
                                .foregroundStyle(Color.fText)
                        }
                    }
                    .opacity(opacity)
                    .animation(.easeIn(duration: 2), value: opacity)

                }
            }
        }
        .onAppear {
            Task {
                try await authModel.getInitialProfile { profiles in
                    DispatchQueue.main.async {
                        withAnimation {
                            userprofiles = profiles
                            receivedProfile = true
                        }
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $start) {
            ContentView()
                .environmentObject(authModel)
        }
    }
}

#Preview {
    SignedInPopupView()
}
