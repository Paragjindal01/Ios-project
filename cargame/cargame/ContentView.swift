import SwiftUI

// MARK: - Main SwiftUI View
struct ContentView: View {
    @State private var score: Int = 0
    @State private var highScore: Int = 0
    @State private var isGameOver: Bool = false
    @State private var showingGameView: Bool = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    colorScheme == .dark ? Color(UIColor.darkGray) : Color(UIColor.systemBlue),
                    colorScheme == .dark ? Color.black : Color(UIColor.systemIndigo)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            if showingGameView {
                // Game view
                GameView(score: $score, isGameOver: $isGameOver)
                    .edgesIgnoringSafeArea(.all)
                    .onChange(of: isGameOver) { newValue in
                        if newValue {
                            if score > highScore {
                                highScore = score
                            }
                        }
                    }
                
                // Exit button with improved positioning
                VStack {
                        HStack {
                            // Exit button moved to top-left
                            Button(action: {
                                showingGameView = false
                            }) {
                                HStack {
                                    Image(systemName: "xmark.circle.fill")
                                    Text("Exit")
                                }
                                .font(.headline)
                                .padding(8)
                                .background(
                                    Capsule()
                                        .fill(Color.red)
                                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 0)
                                )
                                .foregroundColor(.white)
                            }
//                            .padding(.top, 5)
                            .padding(.leading, 5)
                            
                            Spacer()
                        }
                        Spacer()
                    }
                
                
            } else {
                // Main menu with improved styling
                VStack(spacing: 25) {
                    // Title with shadow and effects
                    Text("ROAD RUNNER")
                        .font(.system(size: 46, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 2)
                        .padding(.top, 40)
                    
                    // Score container with glass effect
                    VStack(spacing: 15) {
                        HStack {
                            Image(systemName: "trophy.fill")
                                .foregroundColor(.yellow)
                            Text("HIGH SCORE: \(highScore)")
                                .font(.title2.bold())
                        }
                        
                        if isGameOver {
                            HStack {
                                Image(systemName: "flag.checkered")
                                    .foregroundColor(.orange)
                                Text("LAST SCORE: \(score)")
                                    .font(.title3)
                            }
                        }
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 30)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.15))
                            .shadow(color: .black.opacity(0.2), radius: 10)
                    )
                    .padding(.horizontal)
                    
                    Spacer()
                        .frame(height: 20)
                    
                    // Play button with animation
                    Button(action: {
                        withAnimation {
                            isGameOver = false
                            score = 0
                            showingGameView = true
                        }
                    }) {
                        Text(isGameOver ? "PLAY AGAIN" : "START GAME")
                            .font(.headline)
                            .padding(.vertical, 16)
                            .frame(width: 240)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.green)
                                    .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
                            )
                            .foregroundColor(.white)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    Spacer()
                        .frame(height: 10)
                    
                    // Instructions panel
                    VStack(alignment: .leading, spacing: 12) {
                        Text("HOW TO PLAY")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.bottom, 8)
                        
                        InstructionRow(icon: "hand.tap.fill", text: "Tap and drag to move your car")
                        InstructionRow(icon: "exclamationmark.triangle.fill", text: "Avoid the obstacles on the road")
                        InstructionRow(icon: "chart.line.uptrend.xyaxis", text: "Score increases for each obstacle passed")
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.3))
                            .shadow(color: .black.opacity(0.2), radius: 8)
                    )
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Add signature at the bottom
                    Text("Made by Parag")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(0.8)
                        .padding(.bottom, 10)
                }
                .padding()
            }
        }
        .statusBar(hidden: showingGameView)
    }
}

// Custom button style with scale effect
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(), value: configuration.isPressed)
    }
}

// Instruction row component
struct InstructionRow: View {
    var icon: String
    var text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(.yellow)
                .frame(width: 30, height: 30)
            
            Text(text)
                .foregroundColor(.white)
                .font(.system(.body, design: .rounded))
            
            Spacer()
        }
    }
}
