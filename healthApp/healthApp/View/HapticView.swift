import SwiftUI
import CoreHaptics

// Improved gradient background that matches the original design
struct GradientBackgroundView: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.green.opacity(0.8),
                Color.yellow.opacity(0.6),
                Color.orange.opacity(0.6),
                Color.red.opacity(0.8)
            ]),
            startPoint: .bottom,
            endPoint: .top
        )
        .edgesIgnoringSafeArea(.all)
        .background(Color.black)  // Set the background color to black
    }
}

// Score display component
struct ScoreDisplayView: View {
    let score: Int
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        Text("Difficulty Score: \(score)")
            .font(.largeTitle)
            .foregroundColor(.white.opacity(0.8))
            .position(x: width / 2, y: height / 2)
    }
}

// Continue button component
struct ContinueButtonView: View {
    let score: Int
    
    var body: some View {
        VStack {
            Spacer()
            
            NavigationLink(destination: NewTaskForm(difficultyScore: score)) {
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

// Main HapticView
struct HapticView: View {
    // State
    @EnvironmentObject var taskStore: TaskStore
    @State private var difficultyScore: Int = 0
    @State private var engine: CHHapticEngine? = nil
    @State private var showContinueButton: Bool = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                // Original gradient background
                GradientBackgroundView()
                
                // Add gesture handling
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
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
                
                // Score display
                ScoreDisplayView(
                    score: difficultyScore,
                    width: geometry.size.width,
                    height: geometry.size.height
                )
                
                // Continue button (conditionally)
                if showContinueButton {
                    ContinueButtonView(score: difficultyScore)
                }
            }
            .onAppear {
                prepareHaptics()
            }
            .navigationBarHidden(true)  // Hide navigation bar to match original view
        }
    }
    
    // MARK: - Haptic Feedback Methods
    
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

// Preview
struct HapticView_Previews: PreviewProvider {
    static var previews: some View {
        HapticView()
            .environmentObject(TaskStore())
    }
}
