//
//  SpriteSelectView.swift
//  Focus
//
//  Created by Husein Hakim on 22/12/24.
//

import SwiftUI

struct SpriteSelectView: View {
    var body: some View {
        ScrollView {
            ForEach(1...4, id: \.self) {_ in 
                HStack {
                    ForEach(1...3, id: \.self) {_ in
                        ZStack {
                            
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color.black)
                                .frame(width: 125, height: 125)
                            
                            Image("krypton")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 75, height: 75)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SpriteSelectView()
}
