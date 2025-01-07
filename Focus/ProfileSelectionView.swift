//
//  ProfileSelectionView.swift
//  Focus
//
//  Created by Husein Hakim on 07/01/25.
//

import SwiftUI

struct ProfileSelectionView: View {
    @Binding var pfp: PfpList
    var body: some View {
        ZStack {
            Color.fSecondary.opacity(0.3).ignoresSafeArea()
            ScrollView {
                let pfpCases = PfpList.allCases
                let rows = Array(stride(from: 0, to: pfpCases.count, by: 3))
                
                ForEach(rows, id: \.self) { rowIndex in
                    HStack {
                        ForEach(0..<3, id: \.self) { columnIndex in
                            let index = rowIndex + columnIndex
                            if index < pfpCases.count {
                                let currentPfp = pfpCases[index]
                                ZStack {
                                    Circle()
                                        .foregroundStyle(pfp == currentPfp ? Color.fPrimary : Color.fSecondary)
                                        .frame(width: 125, height: 125)

                                    Image(currentPfp.rawValue)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 110, height: 110)
                                        .clipShape(Circle())
                                }
                                .onTapGesture(perform: {
                                    pfp = currentPfp
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
