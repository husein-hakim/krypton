//
//  SignedInPopupView.swift
//  Focus
//
//  Created by Husein Hakim on 07/01/25.
//

import SwiftUI

struct SignedInPopupView: View {
    @StateObject var authModel = AuthModel()
    var body: some View {
        ZStack {
            Color.fPrimary.ignoresSafeArea()
            
            VStack {
                
            }
        }
        .onAppear {
            Task {
                await authModel.getInitialProfile()
            }
        }
    }
}

#Preview {
    SignedInPopupView()
}
