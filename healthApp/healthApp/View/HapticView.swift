import SwiftUI
import CoreHaptics

// Color-shifting rainbow gradient with brighter colors and more intense red
struct RainbowGradientView: View {
    let difficulty: Double // 0.0 to 1.0
    
    var body: some View {
        // Create a gradient that shifts colors based on difficulty
        LinearGradient(
            gradient: difficultyGradient(difficulty),
            startPoint: .bottom,
            endPoint: .top
        )
        .edgesIgnoringSafeArea(.all)
        .background(Color.black) // Fallback background
    }
    
    // Generate gradient based on difficulty level
    private func difficultyGradient(_ difficulty: Double) -> Gradient {
        // Base colors for our rainbow at different difficulty levels
        // Increased opacity of all colors for a brighter look
        let lowColors = [
            Color.blue.opacity(0.7),
            Color.teal.opacity(0.7),
            Color.green.opacity(0.7),
            Color.yellow.opacity(0.6)
        ]
        
        let midColors = [
            Color.teal.opacity(0.7),
            Color.green.opacity(0.8),
            Color.yellow.opacity(0.8),
            Color.orange.opacity(0.7)
        ]
        
        // More intense red at the high end
        let highColors = [
            Color.green.opacity(0.8),
            Color.yellow.opacity(0.9),
            Color.orange.opacity(0.9),
            Color.red.opacity(0.95) // Higher opacity red for more intensity
        ]
        
        // Highest difficulty colors emphasize red even more
        let maxColors = [
            Color.yellow.opacity(0.9),
            Color.orange.opacity(0.95),
            Color.red,                 // Full opacity red
            Color(red: 0.8, green: 0.0, blue: 0.0) // Deep red
        ]
        
        // Enhanced blending between color sets based on difficulty
        if difficulty < 0.3 {
            // Low difficulty: blend from low to mid
            let normalizedDifficulty = difficulty / 0.3
            return Gradient(colors: blendColorArrays(lowColors, midColors, percentage: normalizedDifficulty))
        } else if difficulty < 0.7 {
            // Medium difficulty: blend from mid to high
            let normalizedDifficulty = (difficulty - 0.3) / 0.4
            return Gradient(colors: blendColorArrays(midColors, highColors, percentage: normalizedDifficulty))
        } else {
            // High difficulty: blend from high to max
            let normalizedDifficulty = (difficulty - 0.7) / 0.3
            return Gradient(colors: blendColorArrays(highColors, maxColors, percentage: normalizedDifficulty))
        }
    }
    
    // Blend between two arrays of colors
    private func blendColorArrays(_ fromColors: [Color], _ toColors: [Color], percentage: Double) -> [Color] {
        let count = min(fromColors.count, toColors.count)
        var result = [Color]()
        
        for i in 0..<count {
            result.append(interpolateColor(from: fromColors[i], to: toColors[i], percentage: percentage))
        }
        
        return result
    }
    
    // Helper to blend between two colors
    private func interpolateColor(from: Color, to: Color, percentage: Double) -> Color {
        let clampedPercentage = min(1.0, max(0.0, percentage))
        
        // For simplicity, I'm using UIColor to do the interpolation
        let fromUIColor = UIColor(from)
        let toUIColor = UIColor(to)
        
        var fromR: CGFloat = 0, fromG: CGFloat = 0, fromB: CGFloat = 0, fromA: CGFloat = 0
        var toR: CGFloat = 0, toG: CGFloat = 0, toB: CGFloat = 0, toA: CGFloat = 0
        
        fromUIColor.getRed(&fromR, green: &fromG, blue: &fromB, alpha: &fromA)
        toUIColor.getRed(&toR, green: &toG, blue: &toB, alpha: &toA)
        
        let resultR = fromR + (toR - fromR) * CGFloat(clampedPercentage)
        let resultG = fromG + (toG - fromG) * CGFloat(clampedPercentage)
        let resultB = fromB + (toB - fromB) * CGFloat(clampedPercentage)
        let resultA = fromA + (toA - fromA) * CGFloat(clampedPercentage)
        
        return Color(UIColor(red: resultR, green: resultG, blue: resultB, alpha: resultA))
    }
}

// Main HapticView
struct HapticView: View {
    // Callback to dismiss this view and continue to NewTaskForm
    var dismissAndContinue: (Int) -> Void
    
    // State
    @EnvironmentObject var taskStore: TaskStore
    @State private var difficultyScore: Int = 0
    @State private var engine: CHHapticEngine? = nil
    @State private var showContinueButton: Bool = false
    
    // Computed difficulty for gradient (0-1)
    private var normalizedDifficulty: Double {
        Double(difficultyScore) / 100.0
    }
    
    var body: some View {
        GeometryReader { geometry in
            // Color-shifting rainbow gradient background
            RainbowGradientView(difficulty: normalizedDifficulty)
            
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
            
            // Score display with brighter text
            Text("Difficulty Score: \(difficultyScore)")
                .font(.largeTitle)
                .foregroundColor(.white.opacity(0.9))
                .shadow(radius: 2) // Add shadow for better visibility against changing background
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            
            // Continue button (conditionally)
            if showContinueButton {
                VStack {
                    Spacer()
                    
                    Button(action: {
                        // Call the provided callback with the difficulty score
                        dismissAndContinue(difficultyScore)
                    }) {
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
        // For preview purposes, provide a dummy closure
        HapticView(dismissAndContinue: { _ in })
            .environmentObject(TaskStore())
    }
}
