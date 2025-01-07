//
//  SignupView.swift
//  Focus
//
//  Created by Husein Hakim on 07/01/25.
//

import SwiftUI

struct SignupView: View {
    @State var username: String = ""
    @State var password: String = ""
    @Binding var signup: Bool
    @State var header: String = ""
    let text = "Welcome to Krypton"
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @StateObject var authModel = AuthModel()
    @State var error: String = ""
    
    var body: some View {
        ZStack {
            Color.fPrimary.ignoresSafeArea()
            
            VStack {
                Text(header)
                    .font(.custom("SourceCodePro-Bold", size: 50))
                    .foregroundStyle(Color.fText)
                    .onReceive(timer) { _ in
                        if header.count < text.count {
                            let index = text.index(text.startIndex, offsetBy: header.count)
                            header.append(text[index])
                        }
                    }
                
                VStack(spacing: 15) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: UIScreen.main.bounds.width * 0.8, height: 40)
                            .foregroundStyle(Color.fText)
                        
                        TextField("Username", text: $username)
                            .frame(width: UIScreen.main.bounds.width * 0.8, height: 40)
                            .foregroundStyle(Color.black)
                            .padding(.leading, 10)
                            .font(.custom("SourceCodePro-Regular", size: 18))
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: UIScreen.main.bounds.width * 0.8, height: 40)
                            .foregroundStyle(Color.fText)
                        
                        SecureField("Password", text: $password)
                            .frame(width: UIScreen.main.bounds.width * 0.8, height: 40)
                            .foregroundStyle(Color.black)
                            .padding(.leading, 10)
                            .font(.custom("SourceCodePro", size: 18))
                    }
                }
                
                Button {
                    Task {
                        do {
                            try await authModel.registerNewUser(email: username, password: password)
                            await authModel.isUserAuthenticated()
                        } catch {
                            authModel.errorMessage = "Failed to create Account: \(error.localizedDescription)"
                        }
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 100, height: 50)
                            .foregroundStyle(Color.fSecondary)
                        
                        Text("Sign Up")
                            .font(.custom("SourceCodePro-Regular", size: 20))
                            .foregroundStyle(Color.fText)
                    }
                }
                .padding(.top, 20)
                
                Text("Already have an account? Log In")
                    .foregroundStyle(Color.fText)
                    .font(.custom("SourceCodePro-Bold", size: 18))
                    .onTapGesture {
                        signup = false
                    }
                    .padding(.top, 20)
                
                if let error = authModel.errorMessage {
                    Text(error)
                        .foregroundStyle(Color.red)
                        .font(.custom("SourceCodePro-Bold", size: 18))
                }
            }
        }
        .fullScreenCover(isPresented: $authModel.isLoggedIn) {
            ContentView()
        }
    }
}

#Preview {
    SignupView(signup: .constant(true))
}
