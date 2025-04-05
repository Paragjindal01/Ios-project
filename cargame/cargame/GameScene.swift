import SwiftUI
import SpriteKit

// MARK: - Game Scene
class CarGameScene: SKScene, SKPhysicsContactDelegate {
    
    // Physics Categories
    let carCategory: UInt32 = 0x1 << 0
    let obstacleCategory: UInt32 = 0x1 << 1
    let roadEdgeCategory: UInt32 = 0x1 << 2
    
    // Game Elements
    private var car: SKSpriteNode!
    private var road: SKSpriteNode!
    private var scoreLabel: SKLabelNode!
    
    // Game State
    private var score = 0
    private var gameOver = false
    private var gameStarted = false
    private var lastUpdateTime: TimeInterval = 0
    private var obstacleSpawnRate: TimeInterval = 1.5
    private var timeSinceLastObstacle: TimeInterval = 0
    
    // Car Control
    private var touchLocation: CGPoint = .zero
    
    // Delegate for game state updates
    weak var gameDelegate: GameDelegate?
    private func loadImage(named: String, fallbackColor: UIColor, size: CGSize) -> SKSpriteNode {
        let texture = SKTexture(imageNamed: named)
        if texture.size() != .zero {
            // Image exists and loaded correctly
            let sprite = SKSpriteNode(texture: texture)
            // Set the size while maintaining aspect ratio
            sprite.size = size
            return sprite
        } else {
            // No image found, use fallback color
            return SKSpriteNode(color: fallbackColor, size: size)
        }
    }
    
    override func didMove(to view: SKView) {
        setupPhysics()
        setupSceneElements()
        
        // Wait for tap to start
        let startLabel = SKLabelNode(fontNamed: "Helvetica Bold")
        startLabel.text = "Tap to Start"
        startLabel.fontSize = 40
        startLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        startLabel.name = "startLabel"
        addChild(startLabel)
    }
    
    private func setupPhysics() {
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        // Add road edges to keep car on the road
        let leftEdge = SKNode()
        leftEdge.position = CGPoint(x: 20, y: size.height / 2)
        leftEdge.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 5, height: size.height))
        leftEdge.physicsBody?.isDynamic = false
        leftEdge.physicsBody?.categoryBitMask = roadEdgeCategory
        leftEdge.physicsBody?.contactTestBitMask = carCategory
        addChild(leftEdge)
        
        let rightEdge = SKNode()
        rightEdge.position = CGPoint(x: size.width - 20, y: size.height / 2)
        rightEdge.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 5, height: size.height))
        rightEdge.physicsBody?.isDynamic = false
        rightEdge.physicsBody?.categoryBitMask = roadEdgeCategory
        rightEdge.physicsBody?.contactTestBitMask = carCategory
        addChild(rightEdge)
    }
    
    private func setupSceneElements() {
        // Create the road background
        road = SKSpriteNode(color: .darkGray, size: CGSize(width: size.width, height: size.height))
        road.position = CGPoint(x: size.width / 2, y: size.height / 2)
        road.zPosition = -1
        addChild(road)
        
        // Add road markings
        createRoadMarkings()
        
        // Adjust car size - fix the aspect ratio to avoid squeezing
        // For top-down car images, make the car wider than it is tall
        let carWidth: CGFloat = 70
        let carHeight: CGFloat = 120 // Increased height
        
        // Create the car using a custom image with better proportions
        car = loadImage(named: "car", fallbackColor: .red, size: CGSize(width: carWidth, height: carHeight)   )
        
        // If using a texture, maintain its original aspect ratio
        if let carTexture = car.texture {
            let aspectRatio = carTexture.size().width / carTexture.size().height
            // If texture exists, preserve aspect ratio
            if aspectRatio > 0 {
                let adjustedWidth = carHeight * aspectRatio
                car.size = CGSize(width: adjustedWidth, height: carHeight)
            }
        }
        
        // Position the car
        car.position = CGPoint(x: size.width / 2, y: size.height * 0.2)
        
        // Rotate the car if needed (0 = pointing up for a top-down car)
        car.zRotation = 0
        car.zRotation = CGFloat.pi / 1
        
        // Set up car physics body - make it slightly smaller than the visual size
        // This gives some forgiveness in collisions
        car.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: car.size.width * 0.8, height: car.size.height * 0.8))
        car.physicsBody?.isDynamic = true
        car.physicsBody?.affectedByGravity = false
        car.physicsBody?.categoryBitMask = carCategory
        car.physicsBody?.contactTestBitMask = obstacleCategory | roadEdgeCategory
        car.physicsBody?.collisionBitMask = roadEdgeCategory
        
        addChild(car)
        
        // Create score label (no changes needed here)

        // Update the score label creation in setupSceneElements() method:

        // Create score label with perfectly centered text
//        let scoreBackground = SKShapeNode(rectOf: CGSize(width: 160, height: 50), cornerRadius: 10)
//        scoreBackground.fillColor = UIColor.black.withAlphaComponent(0.7)
//        scoreBackground.strokeColor = .clear
//        // Keep the background where you want it on screen
//        scoreBackground.position = CGPoint(x: size.width - 80, y: size.height - 60)
//        scoreBackground.zPosition = 10
//        addChild(scoreBackground)

        scoreLabel = SKLabelNode(fontNamed: "Helvetica Bold")
        scoreLabel.fontSize = 28  // Slightly larger for better visibility
        scoreLabel.position = CGPoint(x: size.width - 30, y: size.height - 90)
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.fontColor = .red
        scoreLabel.zPosition = 10  // Ensure it stays on top
        addChild(scoreLabel)
    }


    private func createRoadMarkings() {
        // Create dashed lines on the road
        let dashHeight: CGFloat = 50
        let dashWidth: CGFloat = 15
        let numberOfDashes = Int(size.height / (dashHeight * 2)) + 1
        
        // Left lane marker
        let leftLaneX = size.width * 0.33
        for i in 0..<numberOfDashes {
            let dash = SKSpriteNode(color: .white, size: CGSize(width: dashWidth, height: dashHeight))
            dash.position = CGPoint(x: leftLaneX, y: CGFloat(i) * dashHeight * 2)
            dash.name = "roadDash"
            dash.zPosition = -0.5
            addChild(dash)
        }
        
        // Right lane marker
        let rightLaneX = size.width * 0.67
        for i in 0..<numberOfDashes {
            let dash = SKSpriteNode(color: .white, size: CGSize(width: dashWidth, height: dashHeight))
            dash.position = CGPoint(x: rightLaneX, y: CGFloat(i) * dashHeight * 2)
            dash.name = "roadDash"
            dash.zPosition = -0.5
            addChild(dash)
        }
    }

    
    private func moveRoadMarkings() {
        self.enumerateChildNodes(withName: "roadDash") { (node, _) in
            node.position.y -= 10
            
            // If the dash goes off screen, move it back to the top
            if node.position.y < 0 {
                node.position.y = self.size.height
            }
        }
    }
    
    private func startGame() {
        gameStarted = true
        gameOver = false
        score = 0
        scoreLabel.text = "Score: \(score)"
        
        // Remove start label
        childNode(withName: "startLabel")?.removeFromParent()
        
        // Reset car position
        car.position = CGPoint(x: size.width / 2, y: size.height * 0.2)
        
        // Remove any existing obstacles
        self.enumerateChildNodes(withName: "obstacle") { (node, _) in
            node.removeFromParent()
        }
    }
    
   
    private func spawnObstacle() {
        // Define different obstacle types with custom images
        let obstacleTypes = [
            (imageName: "obstacle1", width: CGFloat(80), height: CGFloat(80)),
            (imageName: "obstacle2", width: CGFloat(100), height: CGFloat(70)),
            (imageName: "obstacle3", width: CGFloat(90), height: CGFloat(90))
        ]
        
        // Choose a random obstacle type
        let obstacleType = obstacleTypes.randomElement()!
        
        // Create the obstacle with the custom image
        let obstacle = loadImage(
            named: obstacleType.imageName,
            fallbackColor: [.blue, .orange, .purple].randomElement()!,
            size: CGSize(width: obstacleType.width, height: obstacleType.height)
        )
        
        // Position in one of three lanes
        let lanes = [size.width * 0.16, size.width * 0.5, size.width * 0.84]
        let laneIndex = Int.random(in: 0..<lanes.count)
        
        // Add more space at the top - spawn further up
        obstacle.position = CGPoint(
            x: lanes[laneIndex],
            y: size.height + obstacleType.height + 100 // Added +100 for more space
        )
        obstacle.name = "obstacle"
        
        // Set up physics body for obstacle
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size)
        obstacle.physicsBody?.isDynamic = true
        obstacle.physicsBody?.affectedByGravity = false
        obstacle.physicsBody?.categoryBitMask = obstacleCategory
        obstacle.physicsBody?.contactTestBitMask = carCategory
        obstacle.physicsBody?.collisionBitMask = 0
        
        addChild(obstacle)
        
        // Add warning animation at the top before obstacle appears
        let warningSign = loadImage(named: "warning", fallbackColor: .red, size: CGSize(width: 30, height: 30))
        warningSign.position = CGPoint(x: lanes[laneIndex], y: size.height - 80) // Moved down from top edge
        warningSign.zPosition = 12 // Above score label
        warningSign.alpha = 0.7
        addChild(warningSign)
        
        // Blink warning and then remove
        let blinkAction = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.2),
            SKAction.fadeAlpha(to: 0.7, duration: 0.2)
        ])
        let blinkGroup = SKAction.repeat(blinkAction, count: 3)
        let removeWarning = SKAction.removeFromParent()
        warningSign.run(SKAction.sequence([blinkGroup, removeWarning]))
        
        // Move obstacle down the road (adjust speed slightly for more space)
        let moveAction = SKAction.moveTo(y: -obstacleType.height, duration: 3.5) // Slower speed for more spacing
        let removeAction = SKAction.removeFromParent()
        let sequence = SKAction.sequence([moveAction, removeAction])
        
        obstacle.run(sequence) {
            if !self.gameOver && self.gameStarted {
                self.score += 1
                self.scoreLabel.text = "Score: \(self.score)"
            }
        }
    }
    override func update(_ currentTime: TimeInterval) {
        if !gameStarted || gameOver {
            return
        }
        
        // Calculate delta time
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        let dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        // Spawn obstacles
        timeSinceLastObstacle += dt
        if timeSinceLastObstacle > obstacleSpawnRate {
            spawnObstacle()
            timeSinceLastObstacle = 0
            
            // Gradually increase difficulty by speeding up obstacle spawn rate
            if obstacleSpawnRate > 0.5 {
                obstacleSpawnRate -= 0.02
            }
        }
        
        // Move road markings to create scrolling effect
        moveRoadMarkings()
        
        // Move car horizontally based on touch location
        if touchLocation != .zero {
            let moveAction = SKAction.moveTo(x: touchLocation.x, duration: 0.1)
            car.run(moveAction)
        }
    }
    
    // Handle collisions
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == carCategory | obstacleCategory {
            // Car hit an obstacle
            gameOver = true
            showGameOver()
        }
    }
    private func showGameOver() {
        // Create semi-transparent overlay
        let overlay = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        overlay.fillColor = UIColor.black.withAlphaComponent(0.5)
        overlay.strokeColor = .clear
        overlay.zPosition = 50
        overlay.position = CGPoint(x: size.width/2, y: size.height/2)
        overlay.name = "overlay" // Add name for easy removal
        addChild(overlay)
        
        // Game Over text
        let gameOverLabel = SKLabelNode(fontNamed: "Helvetica Bold")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 50
        gameOverLabel.fontColor = .white
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY + 50)
        gameOverLabel.zPosition = 51
        gameOverLabel.name = "gameOverLabel"
        addChild(gameOverLabel)
        
        // Final score with better styling
        let scoreBackground = SKShapeNode(rectOf: CGSize(width: 200, height: 40), cornerRadius: 10)
        scoreBackground.fillColor = UIColor.black.withAlphaComponent(0.7)
        scoreBackground.strokeColor = .white
        scoreBackground.lineWidth = 2
        scoreBackground.position = CGPoint(x: frame.midX, y: frame.midY - 10)
        scoreBackground.zPosition = 51
        scoreBackground.name = "scoreBackground"
        addChild(scoreBackground)
        
        let finalScoreLabel = SKLabelNode(fontNamed: "Helvetica")
        finalScoreLabel.text = "Final Score: \(score)"
        finalScoreLabel.fontSize = 30
        finalScoreLabel.fontColor = .white
        finalScoreLabel.position = CGPoint(x: 0, y: -10)
        finalScoreLabel.zPosition = 52
        finalScoreLabel.name = "finalScoreLabel"
        scoreBackground.addChild(finalScoreLabel)
        
        // Restart button with background
        let restartBackground = SKShapeNode(rectOf: CGSize(width: 200, height: 50), cornerRadius: 25)
        restartBackground.fillColor = UIColor.systemBlue
        restartBackground.strokeColor = .white
        restartBackground.lineWidth = 2
        restartBackground.position = CGPoint(x: frame.midX, y: frame.midY - 80)
        restartBackground.zPosition = 51
        restartBackground.name = "restartBackground"
        addChild(restartBackground)
        
        let tapToRestartLabel = SKLabelNode(fontNamed: "Helvetica")
        tapToRestartLabel.text = "Tap to Restart"
        tapToRestartLabel.fontSize = 25
        tapToRestartLabel.fontColor = .white
        tapToRestartLabel.position = CGPoint(x: 0, y: -8)
        tapToRestartLabel.zPosition = 52
        tapToRestartLabel.name = "tapToRestartLabel"
        restartBackground.addChild(tapToRestartLabel)
        
        // Notify delegate about game over
        gameDelegate?.gameDidEnd(withScore: score)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if !gameStarted {
            startGame()
            return
        }
        
        if gameOver {
            // Remove game over UI
            self.enumerateChildNodes(withName: "gameOverLabel") { (node, _) in
                node.removeFromParent()
            }
            self.enumerateChildNodes(withName: "scoreBackground") { (node, _) in
                node.removeFromParent()
            }
            self.enumerateChildNodes(withName: "finalScoreLabel") { (node, _) in
                node.removeFromParent()
            }
            self.enumerateChildNodes(withName: "tapToRestartLabel") { (node, _) in
                node.removeFromParent()
            }
            self.enumerateChildNodes(withName: "restartBackground") { (node, _) in
                node.removeFromParent()
            }
            
            // Remove any overlay
            self.enumerateChildNodes(withName: "overlay") { (node, _) in
                node.removeFromParent()
            }
            
            // Reset game
            startGame()
            return
        }
        
        // Store touch location for car movement
        touchLocation = location
    }


    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // Keep tracking touch for car movement
        touchLocation = touch.location(in: self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Stop tracking touch
        touchLocation = .zero
    }
}

// MARK: - Game Delegate Protocol
protocol GameDelegate: AnyObject {
    func gameDidEnd(withScore score: Int)
}
