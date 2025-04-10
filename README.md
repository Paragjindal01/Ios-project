

https://github.com/user-attachments/assets/e3173e33-c216-41fa-8c0c-1cadca774fae

# Road Runner - iOS Car Game

## Project Overview
Road Runner is an iOS racing game built with SwiftUI and SpriteKit. The player controls a car that must navigate a road while avoiding incoming obstacles. The game features:

- Smooth touch-based car controls
- Randomly generated obstacles
- Visual warning system for upcoming obstacles
- Score tracking and high score persistence
- Attractive UI with animated elements
- Game over screen with restart functionality

## Game Controls
- Tap and drag to move your car left and right
- Avoid obstacles to increase your score
- Game speed increases gradually for higher difficulty

## Project Structure

### Core Files

1. **AppDelegate.swift**
   - Entry point for the application
   - Sets up the SwiftUI app structure

2. **ContentView.swift**
   - Main SwiftUI view that handles:
     - Menu screen with play button, high score display, and instructions
     - Game view container
     - Game state management (score, game over conditions)
     - UI styling and animations

3. **GameView.swift**
   - UIViewRepresentable wrapper for SpriteKit
   - Bridges between SwiftUI and SpriteKit
   - Handles communication between game scene and SwiftUI state

4. **GameScene.swift (CarGameScene)**
   - Core game logic implementation:
     - Physics setup for collisions
     - Car movement and control
     - Obstacle generation and movement
     - Road markings and visual elements
     - Score tracking
     - Game over detection and UI

5. **GameViewController.swift**
   - Legacy UIKit controller (not used in the current SwiftUI implementation)

### Supporting Files

6. **LaunchScreen.storyboard**
   - Initial loading screen

7. **Main.storyboard**
   - Legacy storyboard (not used in the current SwiftUI implementation)

## Technical Implementation Details

### Physics System
- Uses SpriteKit's physics engine
- Collision categories for car, obstacles, and road edges
- Contact detection for game over conditions

### Game Elements
- Car sprite with touch-based movement
- Scrolling road with animated lane markings
- Random obstacle generation with varying types
- Warning system before obstacles appear

### UI Framework
- SwiftUI for menus and game container
- Custom styling with animations and effects
- Dynamic dark/light mode support

### Game Loop
1. Player starts game from menu
2. Car appears on road
3. Obstacles spawn at increasing frequency
4. Player moves car to avoid obstacles
5. Score increases for each passed obstacle
6. On collision, game over screen appears
7. Player can restart or exit to menu

## Possible Enhancements
- Add power-ups (speed boosts, shields, etc.)
- Implement different vehicle options
- Add sound effects and background music
- Create leaderboard functionality
- Add difficulty levels

## Development Notes
- Built with Swift 5
- Target iOS 14.0+
- Uses SwiftUI for UI and SpriteKit for game mechanics
- No external dependencies required


# Road Runner - Viva Preparation Guide

## Core Concepts to Understand

### 1. SwiftUI and SpriteKit Integration
- How SwiftUI and SpriteKit are connected in your application
- The role of GameView as a UIViewRepresentable
- How game state is communicated back to SwiftUI

### 2. Game Architecture
- Scene setup and lifecycle methods
- Physics system and collision detection
- Game loop implementation

### 3. UI Implementation
- SwiftUI view hierarchy
- Custom styling and animations
- Menu and game over screens

## Likely Viva Questions and Answers

### Project Structure and Design

**Q: Explain the overall architecture of your application.**
A: The application follows a hybrid architecture combining SwiftUI for the user interface and SpriteKit for the game mechanics. The ContentView handles the main menu and game state, while GameView acts as a bridge to the SpriteKit scene where the actual gameplay occurs. The CarGameScene class manages all game logic including physics, collision detection, and obstacle generation.

**Q: How does your application handle communication between SwiftUI and SpriteKit?**
A: The communication is handled through two mechanisms:
1. The GameView implements UIViewRepresentable to wrap the SpriteKit view
2. A Coordinator pattern is used with the GameDelegate protocol to send game events (like game over) back to SwiftUI
3. Binding variables are used to update score and game state in the ContentView

### Game Implementation

**Q: Explain how collision detection works in your game.**
A: Collision detection uses SpriteKit's physics system:
1. Physics categories are defined for the car, obstacles, and road edges
2. The scene implements SKPhysicsContactDelegate
3. Physics bodies are attached to game elements with appropriate category and contact test bitmasks
4. The didBegin(_:) method detects when collisions occur
5. When the car collides with an obstacle, the game over state is triggered

**Q: How do you generate and manage obstacles?**
A: Obstacles are generated through the spawnObstacle() method which:
1. Selects a random obstacle type from predefined options
2. Positions it in one of three lanes at the top of the screen
3. Shows a warning animation before the obstacle appears
4. Uses SKActions to move the obstacle down the screen
5. Removes the obstacle when it leaves the screen
6. Increases the score when an obstacle is successfully avoided
7. Gradually increases spawn rate for difficulty progression

### UI Features

**Q: Describe the UI elements and animations in your game.**
A: The UI includes:
1. A main menu with animated buttons and glass-like effects
2. Dynamic background gradients that adapt to light/dark mode
3. Animated instructions with icons
4. In-game score display
5. Game over overlay with final score and restart button
6. Custom button animations using ScaleButtonStyle
7. Road markings that continuously scroll to create movement effect

**Q: How did you implement the car movement controls?**
A: Car movement is implemented through touch handling:
1. touchesBegan, touchesMoved, and touchesEnded track user input
2. Touch location is stored and updated as the user drags
3. In the update method, the car moves horizontally toward the touch location
4. SKActions are used for smooth movement animation
5. Physics bodies on the road edges prevent the car from leaving the road

### Technical Implementation

**Q: How does your game handle different screen sizes and orientations?**
A: The game adapts to different screen sizes by:
1. Using the device's screen bounds to size the game scene
2. Positioning UI elements relative to the frame dimensions
3. Using SwiftUI's layout system for responsive menu design
4. Setting appropriate scale modes for the SpriteKit scene

**Q: Explain how you've implemented the scoring system.**
A: The scoring system works by:
1. Initializing score to zero when the game starts
2. Incrementing score when an obstacle successfully passes off screen
3. Displaying the current score in the top corner during gameplay
4. Updating the high score in ContentView if the current score is higher
5. Showing the final score on the game over screen

## Technical Details to Review

### Physics System Configuration
```swift
private func setupPhysics() {
    physicsWorld.gravity = .zero
    physicsWorld.contactDelegate = self
    
    // Road edges setup...
}
```

### Obstacle Generation and Movement
```swift
private func spawnObstacle() {
    // Obstacle creation code...
    
    // Position in one of three lanes
    let lanes = [size.width * 0.16, size.width * 0.5, size.width * 0.84]
    
    // Warning animation...
    
    // Move obstacle down the road
    let moveAction = SKAction.moveTo(y: -obstacleType.height, duration: 3.5)
    let removeAction = SKAction.removeFromParent()
    let sequence = SKAction.sequence([moveAction, removeAction])
    
    obstacle.run(sequence) {
        if !self.gameOver && self.gameStarted {
            self.score += 1
            self.scoreLabel.text = "Score: \(self.score)"
        }
    }
}
```

### Collision Detection
```swift
func didBegin(_ contact: SKPhysicsContact) {
    let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
    
    if collision == carCategory | obstacleCategory {
        // Car hit an obstacle
        gameOver = true
        showGameOver()
    }
}
```

### SwiftUI-SpriteKit Communication
```swift
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
```

## Feature Highlights to Emphasize

1. **Integration of Modern Frameworks**: Using SwiftUI alongside SpriteKit
2. **Responsive Design**: Adapts to different iOS devices and screen sizes
3. **Physics-Based Gameplay**: Using SpriteKit's physics engine for realistic collisions
4. **Progressive Difficulty**: Game becomes harder as player advances
5. **Visual Feedback Systems**: Warning indicators for upcoming obstacles
6. **State Management**: Clean separation between UI state and game logic
7. **Custom Animations**: Button effects, scrolling road, and transition animations
