import SwiftUI
import SpriteKit
// MARK: - SpriteKit View
struct GameView: UIViewRepresentable {
    @Binding var score: Int
    @Binding var isGameOver: Bool
    
    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.preferredFramesPerSecond = 60
        view.showsFPS = true
        view.showsNodeCount = true
        
        // Create and configure the game scene
        let scene = CarGameScene(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        scene.scaleMode = .aspectFill
        scene.gameDelegate = context.coordinator
        
        // Present the scene
        view.presentScene(scene)
        
        return view
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        // Updates from SwiftUI to UIKit
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, GameDelegate {
        var parent: GameView
        
        init(_ parent: GameView) {
            self.parent = parent
        }
        
        func gameDidEnd(withScore score: Int) {
            // Update SwiftUI state
            DispatchQueue.main.async {
                self.parent.score = score
                self.parent.isGameOver = true
            }
        }
    }
}
