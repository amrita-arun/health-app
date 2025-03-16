//
//  HapticView.swift
//  healthApp
//
//  Created by Shruti Natala on 2/23/25.
//

import SwiftUI
import CoreHaptics

struct HapticView: View {
    @State private var difficultyScore: Int = 0
    @State private var engine: CHHapticEngine?
    @State private var showContinueButton = false
    @State private var navigateToNewTaskForm = false
    
    var body: some View {
        NavigationStack{
            GeometryReader { geometry in
                LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.8), Color.yellow.opacity(0.6), Color.orange.opacity(0.6), Color.red.opacity(0.8)]),
                               startPoint: .bottom, endPoint: .top)
                    .edgesIgnoringSafeArea(.all)
                    .background(Color.black)  // Set the background color to black
                    .gesture(DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let height = geometry.size.height
                            let position = value.location.y
                            difficultyScore = max(0, min(100, Int((1 - (position / height)) * 100)))
                            triggerHapticFeedback(intensity: Float(difficultyScore) / 100)
                        }
                        .onEnded { _ in
                            stopHapticFeedback()
                            
                            withAnimation {
                                showContinueButton = true
                            }
                            
                        }
                    )
                    
                Text("Difficulty Score: \(difficultyScore)")
                    .font(.largeTitle)
                    .foregroundColor(.white.opacity(0.8))
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                
                if showContinueButton {
                        VStack {
                            Spacer()
                            NavigationLink {
                                NewTaskForm()
                            } label: {
                                
                                    Text("Continue")
                                        .font(.headline)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.white)
                                        .foregroundColor(.blue)
                                        .cornerRadius(10)
                                        .padding(.horizontal)
                                        .padding(.bottom, 20)
                                
                            }
                        }
                        .transition(.move(edge: .bottom))
                    }
            }
            .onAppear {
                prepareHaptics()
            }
        }
        
    }
    
    private func prepareHaptics() {
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptic Engine Error: \(error.localizedDescription)")
        }
    }
    
    private func triggerHapticFeedback(intensity: Float) {
        guard let engine = engine else { return }
        
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: intensity)
        let intensityParam = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
        
        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [sharpness, intensityParam], relativeTime: 0, duration: 0.1)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makeAdvancedPlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Haptic Playback Error: \(error.localizedDescription)")
        }
    }
    
    private func stopHapticFeedback() {
        engine?.stop(completionHandler: { _ in })
        
    }
}

struct HapticView_Previews: PreviewProvider {
    static var previews: some View {
        HapticView()
    }
}
