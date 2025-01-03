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
    
    var score = 0
    var bestScore = 0
    
    let cam = SKCameraNode()
    var isCamFollowingPlayer: Bool = false
    
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
        
        scoreLabel.position.x = 100
        scoreLabel.zPosition = 20
        
        cam.setScale(1)
        cam.position = CGPoint(x: size.width / 2, y: size.height / 2)
        camera = cam
        
        setupInitialPlatforms()
    }
    
    override func update(_ currentTime: TimeInterval) {
        if player.position.y > UIScreen.main.bounds.height * 0.5 {
            cam.position.y = player.position.y
            background.position.y = player.position.y

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
        
        view?.presentScene(gameOverScene, transition: transition)
        
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
    
    func setupInitialPlatforms() {
        let numberOfInitialPlatforms = 6
        let spacing = 200

        for i in 0..<numberOfInitialPlatforms {
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
}
