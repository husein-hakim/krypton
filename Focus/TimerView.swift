//
//  ContentView.swift
//  Focus
//
//  Created by Husein Hakim on 15/12/24.
//

import SwiftUI
import FamilyControls
import ManagedSettings

struct TimerView: View {
    enum Mode: String, CaseIterable, Identifiable {
        case timer = "timer.circle.fill"
        case stopwatch = "hourglass"
        
        var id: Self {self}
    }
    @State var mode: Mode = .timer
    @State var timer: Double = 15.0
    @State var isFocus: Bool = false
    @State var options: Bool = false
    @State var selectedKrypton: String = "krypton"
    
    var body: some View {
        ZStack {
            Color.fPrimary.ignoresSafeArea()
            
            VStack {
                Text("Start your journey today!")
                    .foregroundStyle(Color.white)
                    .font(.custom("SourceCodePro-Bold", size: 16))
                
                Spacer()
                
                CircularTimeSlider(selectedTime: $timer, options: $options, selectedImage: $selectedKrypton)
                
                Text("\(Int(timer)):00")
                    .font(.custom("SourceCodePro-Regular", size: 40))
                    .foregroundColor(.fSecondary)
                    .padding()
                
                Spacer()
                
                Button {
                    withAnimation {
                        isFocus = true
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundStyle(Color.fSecondary)
                            .shadow(radius: 10, x: -50, y: 10)

                        Text("Focus")
                            .foregroundStyle(Color.fText)
                            .font(.custom("SourceCodePro-Bold", size: 16))
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .frame(width: 75, height: 35)
                .fullScreenCover(isPresented: $isFocus) {
                    HomeView(minutes: timer, isFocus: $isFocus, selectedKrypton: selectedKrypton)
                }
                .sheet(isPresented: $options, content: {
                    SpriteSelectView(selectedKrypton: $selectedKrypton)
                        .presentationDetents([.medium])
                })
                .padding()
                
                Text("You will earn: \(String(format: "%.0f", floor(timer/15)))")
                    .font(.custom("SourceCodePro-Regular", size: 18))
                    .foregroundStyle(Color.fText)
                
                Spacer()
            }
        }
        .onChange(of: selectedKrypton) { oldValue, newValue in
            print("krypton is \(newValue)")
        }
    }
}

struct CircularTimeSlider: View {
    @Binding var selectedTime: Double
    @State private var dragAngle: Double = 0.0
    
    let minTime: Double = 1
    let maxTime: Double = 120
    
    @Binding var options: Bool
    @Binding var selectedImage: String
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                .frame(width: 250, height: 250)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(selectedTime / maxTime))
                .stroke(Color.fSecondary, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 250, height: 250)
            
            Image(selectedImage)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .onTapGesture {
                    options = true
                }
            
            GeometryReader { geometry in
                let size = geometry.size
                let knobPosition = self.knobPosition(for: size)
                
                Circle()
                    .fill(Color.fTertiary)
                    .frame(width: 25, height: 25)
                    .position(knobPosition)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                self.updateSelectedTime(from: value, in: size)
                            }
                    )
            }
            .frame(width: 250, height: 250)
        }
    }
    
    private func knobPosition(for size: CGSize) -> CGPoint {
        let radius = size.width / 2
        let angle = Angle.degrees((selectedTime / maxTime) * 360.0 - 90)
        let x = size.width / 2 + CGFloat(cos(angle.radians)) * radius
        let y = size.height / 2 + CGFloat(sin(angle.radians)) * radius
        return CGPoint(x: x.rounded(), y: y.rounded())
    }
    
    private func updateSelectedTime(from value: DragGesture.Value, in size: CGSize) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let deltaX = value.location.x - center.x
        let deltaY = value.location.y - center.y
        let angle = atan2(deltaY, deltaX) * 180 / .pi + 90
        let normalizedAngle = (angle < 0 ? angle + 360 : angle) // Normalize angle to 0-360
        let progress = normalizedAngle / 360.0
        let newTime = minTime + progress * (maxTime - minTime)

        selectedTime = min(max(newTime, minTime), maxTime).rounded() // Clamp between minTime and maxTime
    }
}
