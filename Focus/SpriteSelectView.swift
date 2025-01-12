//
//  SpriteSelectView.swift
//  Focus
//
//  Created by Husein Hakim on 22/12/24.
//

import SwiftUI

struct SpriteSelectView: View {
    @State var sprite: SpriteOptions = .krypton
    @Binding var selectedKrypton: String
    var body: some View {
        ZStack {
            Color.fSecondary.opacity(0.3).ignoresSafeArea()
            ScrollView {
                let spriteCases = SpriteOptions.allCases
                let rows = Array(stride(from: 0, to: spriteCases.count, by: 3))
                
                ForEach(rows, id: \.self) { rowIndex in
                    HStack {
                        ForEach(0..<3, id: \.self) { columnIndex in
                            let index = rowIndex + columnIndex
                            if index < spriteCases.count {
                                let currentSprite = spriteCases[index]
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundStyle(sprite == currentSprite ? Color.fPrimary : Color.fSecondary)
                                        .frame(width: 90, height: 100)

                                    Image(currentSprite.rawValue)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 80)
                                }
                                .onTapGesture(perform: {
                                    sprite = currentSprite
                                    selectedKrypton = currentSprite.rawValue
                                    print("selected krypton is \(selectedKrypton)")
                                })
                                .padding()
                            } else {
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
    }
}
