//
//  GameOverScene.swift
//  Focus
//
//  Created by Husein Hakim on 03/01/25.
//

import Foundation
import SpriteKit
import SwiftUI

class GameOverScene: SKScene {
    let background = SKSpriteNode(imageNamed: "background")
    let gameOver = SKSpriteNode(imageNamed: "game-over")
    var character: String?
    var dismissAction: (() -> Void)?
    
    override func didMove(to view: SKView) {
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(background)
        
        gameOver.position = CGPoint(x: size.width / 2, y: size.height / 1.5)
        gameOver.setScale(0.4)
        gameOver.zPosition = 5
        addChild(gameOver)
        
        let tapLabel = SKLabelNode(fontNamed: "SourceCodePro-Bold")
        tapLabel.text = "Tap to play again"
        tapLabel.fontSize = 30
        tapLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 50)
        tapLabel.zPosition = 5
        tapLabel.fontColor = .black
        tapLabel.name = "playAgain"
        addChild(tapLabel)
        
        let exitButton = SKSpriteNode(color: .red, size: CGSize(width: 100, height: 40))
        exitButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 150)
        exitButton.zPosition = 5
        addChild(exitButton)
        
        let exitLabel = SKLabelNode(fontNamed: "SourceCodePro-Bold")
        exitLabel.text = "Exit"
        exitLabel.fontSize = 20
        exitLabel.fontColor = .white
        exitLabel.verticalAlignmentMode = .center
        exitLabel.position = CGPoint(x: 0, y: 0)
        exitLabel.name = "exitButton"
        exitButton.addChild(exitLabel)
        
        let outAction = SKAction.fadeOut(withDuration: 0.5)
        let inAction = SKAction.fadeIn(withDuration: 0.5)
        let sequence = SKAction.sequence([outAction, inAction])
        
        tapLabel.run(SKAction.repeatForever(sequence))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        if touchedNode.name == "exitButton" {
            print("exit")
            dismissAction?()
            //return
        } else if touchedNode.name == "playAgain"{
            let gameScene = GameScene(size: self.size)
            gameScene.character = character
            gameScene.dismissAction = dismissAction
            let transition = SKTransition.fade(withDuration: 0.5)
            view?.presentScene(gameScene, transition: transition)
        }
    }
}
