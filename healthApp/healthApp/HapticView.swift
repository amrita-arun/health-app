//
//  HapticView.swift
//  healthApp
//

import SwiftUI
import CoreHaptics

struct HapticView: View {
    // MARK: - Environment Objects
    @EnvironmentObject var activityViewModel: ActivityViewModel
    
    // MARK: - Bindings
    /// Binding to control this view's presentation
    @Binding var isPresented: Bool
    
    // MARK: - State Management
    @State private var difficultyScore: Int = 0
    @State private var engine: CHHapticEngine?
    @State private var showActivityLog = false
    @State private var touchEnded = false
    
    // MARK: - UI Layout
    var body: some View {
        GeometryReader { geometry in
            // Gradient Background
            LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.8), Color.yellow.opacity(0.6), Color.orange.opacity(0.6), Color.red.opacity(0.8)]),
                           startPoint: .bottom, endPoint: .top)
                .edgesIgnoringSafeArea(.all)
                .background(Color.black)
                .gesture(DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        touchEnded = false
                        
                        let height = geometry.size.height
                        let position = value.location.y
                        difficultyScore = max(0, min(100, Int((1 - (position / height)) * 100)))
                        triggerHapticFeedback(intensity: Float(difficultyScore) / 100)
                    }
                    .onEnded { _ in
                        stopHapticFeedback()
                        touchEnded = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            if touchEnded {
                                showActivityLog = true
                            }
                        }
                    }
                )
            
            // Score Display
            VStack {
                Text("Difficulty Score: \(difficultyScore)")
                    .font(.largeTitle)
                    .foregroundColor(.white.opacity(0.8))
                
                Text("Release to log your activity")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.top, 10)
            }
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            
            // Cancel Button
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white.opacity(0.8))
                            .padding()
                    }
                }
                Spacer()
            }
        }
        .onAppear {
            prepareHaptics()
        }
        .fullScreenCover(isPresented: $showActivityLog) {
            ActivityLogView(
                viewModel: activityViewModel,
                hapticViewPresented: $isPresented,  // Moved before difficultyScore
                difficultyScore: difficultyScore
            )
        }
    }
    
    // MARK: - Haptic Functions
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

// MARK: - Preview
struct HapticView_Previews: PreviewProvider {
    static var previews: some View {
        HapticView(isPresented: .constant(true))
            .environmentObject(ActivityViewModel(isPreview: true))
    }
}
