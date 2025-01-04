//
//  GameOverScene.swift
//  Focus
//
//  Created by Husein Hakim on 03/01/25.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    let background = SKSpriteNode(imageNamed: "background")
    let gameOver = SKSpriteNode(imageNamed: "game-over")
    
    override func didMove(to view: SKView) {
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(background)
        
        gameOver.position = CGPoint(x: size.width / 2, y: size.height / 1.5)
        gameOver.setScale(0.4)
        gameOver.zPosition = 5
        addChild(gameOver)
        
        let tapLabel = SKLabelNode(fontNamed: "HelveticaNeue-Light")
        tapLabel.text = "Tap to play again"
        tapLabel.fontSize = 30
        tapLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 50)
        tapLabel.zPosition = 5
        tapLabel.fontColor = .black
        addChild(tapLabel)
        
        let outAction = SKAction.fadeOut(withDuration: 0.5)
        let inAction = SKAction.fadeIn(withDuration: 0.5)
        let sequence = SKAction.sequence([outAction, inAction])
        
        tapLabel.run(SKAction.repeatForever(sequence))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let gameScene = GameScene(size: self.size)
        let transition = SKTransition.fade(withDuration: 0.5)
        
        view?.presentScene(gameScene, transition: transition)
    }
}
