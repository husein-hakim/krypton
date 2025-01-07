//
//  LoginView.swift
//  Focus
//
//  Created by Husein Hakim on 07/01/25.
//

import SwiftUI

struct LoginView: View {
    @State var username: String = ""
    @State var password: String = ""
    @State var signUp: Bool = false
    @State var header: String = ""
    let text = "Focus with Krypton"
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
                            try await authModel.signInWithEmail(email: username, password: password)
                            await authModel.isUserAuthenticated()
                        } catch {
                            authModel.errorMessage = "Failed to log in: \(error.localizedDescription)"
                        }
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 100, height: 50)
                            .foregroundStyle(Color.fSecondary)
                        
                        Text("LOGIN")
                            .font(.custom("SourceCodePro-Regular", size: 20))
                            .foregroundStyle(Color.fText)
                    }
                }
                .padding(.top, 20)
                
                Text("Don't have an account? Sign up")
                    .foregroundStyle(Color.fText)
                    .font(.custom("SourceCodePro-Regular", size: 18))
                    .onTapGesture {
                        signUp = true
                    }
                
                if let error = authModel.errorMessage {
                    Text(error)
                        .foregroundStyle(Color.red)
                        .font(.custom("SourceCodePro-Regular", size: 18))
                }
            }
        }
        .fullScreenCover(isPresented: $signUp) {
            SignupView(signup: $signUp)
        }
        .fullScreenCover(isPresented: $authModel.isLoggedIn) {
            ContentView()
        }
    }
}

#Preview {
    LoginView()
}
