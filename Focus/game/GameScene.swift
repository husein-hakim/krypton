//
//  GameScene.swift
//  Focus
//
//  Created by Husein Hakim on 03/01/25.
//

import SwiftUI
import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    let background = SKSpriteNode(imageNamed: "background")
    let player = SKSpriteNode(imageNamed: "krypton")
    let ground = SKSpriteNode(imageNamed: "land-grass")
    let gameOverLine = SKSpriteNode(color: .red, size: CGSize(width: 1000, height: 10))
    var firstTouch: Bool = false
    let scoreLabel = SKLabelNode(fontNamed: "HelveticaNeue-Light")
    
    var previousPlayerY: CGFloat = 0
    var score = 0
    var bestScore = 0
    var downwardForce: CGFloat = 0.0
    
    let cam = SKCameraNode()
    var isCamFollowingPlayer: Bool = false
    
    let audioPlayer = AudioPlayer()
    
    enum bitmasks: UInt32 {
        case player = 0b1
        case platform = 0b10
        case gameOverLine
    }
    
    override func didMove(to view: SKView) {
        self.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        self.anchorPoint = .zero
        
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = 1
        background.setScale(0.455)
        addChild(background)
        
        physicsWorld.contactDelegate = self
        
        ground.position = CGPoint(x: size.width / 2, y: 35)
        ground.zPosition = 5
        ground.setScale(0.12)
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.allowsRotation = false
        ground.physicsBody?.affectedByGravity = false
        addChild(ground)
        
        player.position = CGPoint(x: size.width / 2, y: size.height / 14)
        player.zPosition = 10
        player.setScale(0.2)
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.height / 2)
        player.physicsBody?.isDynamic = false
        player.physicsBody?.restitution = 1
        player.physicsBody?.friction = 0
        player.physicsBody?.angularDamping = 0
        player.physicsBody?.categoryBitMask = bitmasks.player.rawValue
        player.physicsBody?.collisionBitMask = 0
        player.physicsBody?.contactTestBitMask = bitmasks.platform.rawValue | bitmasks.gameOverLine.rawValue
        addChild(player)
        
        gameOverLine.position = CGPoint(x: player.position.x, y: player.position.y - 200)
        gameOverLine.zPosition = -1
        gameOverLine.physicsBody = SKPhysicsBody(rectangleOf: gameOverLine.size)
        gameOverLine.physicsBody?.affectedByGravity = false
        gameOverLine.physicsBody?.allowsRotation = false
        gameOverLine.physicsBody?.categoryBitMask = bitmasks.gameOverLine.rawValue
        gameOverLine.physicsBody?.contactTestBitMask = bitmasks.platform.rawValue | bitmasks.gameOverLine.rawValue
        addChild(gameOverLine)
        
        scoreLabel.fontColor = .black
        scoreLabel.fontSize = 30
        scoreLabel.position.x = 75
        scoreLabel.zPosition = 20
        scoreLabel.position.y = size.height - 80
        scoreLabel.text = "Score: \(score)"
        addChild(scoreLabel)
        
        cam.setScale(1)
        cam.position = CGPoint(x: size.width / 2, y: size.height / 2)
        camera = cam
        
        setupInitialPlatforms()
    }
    
    override func update(_ currentTime: TimeInterval) {
        updateScore()
        removeOffscreenPlatforms()
        downwardForce += 0.5
        if player.position.y > UIScreen.main.bounds.height * 0.5 {
            cam.position.y = player.position.y
            background.position.y = player.position.y
            scoreLabel.position.y = player.position.y + size.height * 0.4
            previousPlayerY = player.position.y

            if let highestPlatform = children.filter({ $0.name == "platform" })
                .max(by: { $0.position.y < $1.position.y }) {

                let minSpacing: CGFloat = 100 // Minimum vertical spacing
                let maxSpacing: CGFloat = 400 // Maximum vertical spacing

                // Generate a new platform if the highest is too low compared to the player
                if highestPlatform.position.y < player.position.y + 400 && Bool.random() {
                    let nextPlatformY = highestPlatform.position.y + CGFloat.random(in: minSpacing...maxSpacing)
                    createPlatform(atHeightRange: Int(nextPlatformY)...Int(nextPlatformY))
                }
            }
        }

        if player.physicsBody!.velocity.dy > 0 {
            gameOverLine.position.y = player.position.y - 600
        } else {
            player.physicsBody?.applyForce(CGVector(dx: 0, dy: -downwardForce))
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactA: SKPhysicsBody
        let contactB: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            contactA = contact.bodyA
            contactB = contact.bodyB
        } else {
            contactA = contact.bodyB
            contactB = contact.bodyA
        }
        
        if contactA.categoryBitMask == bitmasks.platform.rawValue && contactB.categoryBitMask == bitmasks.player.rawValue {
            contactA.node?.removeFromParent()
        }
        
        if contactA.categoryBitMask == bitmasks.player.rawValue && contactB.categoryBitMask == bitmasks.platform.rawValue {
            if player.physicsBody!.velocity.dy < 0 {
                player.physicsBody?.velocity = CGVector(dx: (player.physicsBody!.velocity.dx), dy: 1150)
                contactB.node?.removeFromParent()
                updateScore()
                audioPlayer.playSoundOnce(fileName: "jump", fileType: ".mp3")
            }
        }
        
        if contactA.categoryBitMask == bitmasks.player.rawValue && contactB.categoryBitMask == bitmasks.gameOverLine.rawValue {
            gameOver()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let lokation = touch.location(in: self)
            
            player.position.x = lokation.x
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        player.physicsBody?.isDynamic = true
        
        if !firstTouch {
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 350))
        }
        firstTouch = true
    }
    
    func gameOver() {
        let gameOverScene = GameOverScene(size: self.size)
        let transition = SKTransition.crossFade(withDuration: 0.5)
        removeOffscreenPlatforms()
        audioPlayer.playSoundOnce(fileName: "fall", fileType: ".mp3")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.view?.presentScene(gameOverScene, transition: transition)
        }
    }
    
    func createPlatform(atHeightRange range: ClosedRange<Int>) {
        guard let yPosition = range.first else { return } // Ensure a valid height

        let platform = SKSpriteNode(imageNamed: "floating-grass")
        platform.position = CGPoint(
            x: GKRandomDistribution(lowestValue: 70, highestValue: Int(size.width - 70)).nextInt(),
            y: yPosition
        )
        platform.setScale(0.3)
        platform.zPosition = 5
        let hitboxSize = CGSize(width: platform.size.width, height: platform.size.height * 0.8) // Adjust height (80% of the sprite's height)
        let hitboxCenter = CGPoint(x: 0, y: -platform.size.height * 0.2) // Lower by 10% of the sprite's height

        platform.physicsBody = SKPhysicsBody(rectangleOf: hitboxSize, center: hitboxCenter)
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.allowsRotation = false
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.categoryBitMask = bitmasks.platform.rawValue
        platform.physicsBody?.collisionBitMask = 0
        platform.physicsBody?.contactTestBitMask = bitmasks.player.rawValue
        platform.name = "platform"
        
        if score > 500{
            let shouldMove = Bool.random() // Randomly decide if this platform should move
            if shouldMove {
                let movementDistance: CGFloat = CGFloat.random(in: 50...150) // Movement range
                let movementDuration: TimeInterval = TimeInterval.random(in: 0.3...2.0) // Movement speed
                let moveLeft = SKAction.moveBy(x: -movementDistance, y: 0, duration: movementDuration)
                let moveRight = SKAction.moveBy(x: movementDistance, y: 0, duration: movementDuration)
                let movementSequence = SKAction.sequence([moveLeft, moveRight])
                let repeatMovement = SKAction.repeatForever(movementSequence)
                platform.run(repeatMovement)
            }
        }
        
        if score > 1000 {
            let movementType = Int.random(in: 1...3)
            
            switch movementType {
            case 1:
                let movementDistance: CGFloat = CGFloat.random(in: 50...150) // Movement range
                let movementDuration: TimeInterval = TimeInterval.random(in: 0.3...2.0) // Movement speed
                let moveLeft = SKAction.moveBy(x: -movementDistance, y: 0, duration: movementDuration)
                let moveRight = SKAction.moveBy(x: movementDistance, y: 0, duration: movementDuration)
                let movementSequence = SKAction.sequence([moveLeft, moveRight])
                let repeatMovement = SKAction.repeatForever(movementSequence)
                platform.run(repeatMovement)
                
            case 2:
                let movementDistance: CGFloat = CGFloat.random(in: 50...150 + CGFloat(score))
                let movementDuration: TimeInterval = max(0.5, 4.0 - Double(score) * 0.1)
                let moveLeft = SKAction.moveBy(x: -movementDistance, y: 0, duration: movementDuration)
                let moveRight = SKAction.moveBy(x: movementDistance, y: 0, duration: movementDuration)
                let pause = SKAction.wait(forDuration: TimeInterval.random(in: 0.5...2.0))
                let movementSequence = SKAction.sequence([moveLeft, pause, moveRight, pause])
                let repeatMovement = SKAction.repeatForever(movementSequence)
                platform.run(repeatMovement)
                
            case 3:
                break
                
            default:
                break
            }
        }

        addChild(platform)
    }
    
    func setupInitialPlatforms() {
        let numberOfInitialPlatforms = 6
        let spacing = 200

        for i in 1..<numberOfInitialPlatforms {
            let platform = SKSpriteNode(imageNamed: "floating-grass")
            platform.position = CGPoint(
                x: GKRandomDistribution(lowestValue: 70, highestValue: Int(size.width - 70)).nextInt(),
                y: Int(player.position.y) + i * spacing
            )
            platform.setScale(0.3)
            platform.zPosition = 5
            platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
            platform.physicsBody?.isDynamic = false
            platform.physicsBody?.allowsRotation = false
            platform.physicsBody?.affectedByGravity = false
            platform.physicsBody?.categoryBitMask = bitmasks.platform.rawValue
            platform.physicsBody?.collisionBitMask = 0
            platform.physicsBody?.contactTestBitMask = bitmasks.player.rawValue
            platform.name = "platform"

            addChild(platform)
        }
    }
    
    func removeOffscreenPlatforms() {
        let thresholdHeight = player.position.y - 600 // Adjust threshold as needed

        children
            .filter { $0.name == "platform" && $0.position.y < thresholdHeight }
            .forEach { $0.removeFromParent() }
    }
    
    func updateScore() {
        withAnimation {
            if player.position.y > previousPlayerY {
                score = Int(player.position.y / 10) - 6
            }
        }
        scoreLabel.text = "Score: \(score)"
    }
}
