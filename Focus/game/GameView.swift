//
//  GameView.swift
//  Focus
//
//  Created by Husein Hakim on 03/01/25.
//

import SwiftUI
import SpriteKit

class StartScene: SKScene {
    var character: String?
    var isPresented: Binding<Bool>?
    
    override func didMove(to view: SKView) {
        self.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        scene?.scaleMode = .aspectFill
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let lokation = touch.location(in: self)
            let startNode = atPoint(lokation)
            
            if startNode.name == "startButton" {
                let game = GameScene(size: self.size)
                game.character = self.character
                game.dismissAction = { [weak self] in
                    self?.isPresented?.wrappedValue = false
                }
                let transition = SKTransition.fade(withDuration: 1.2)
                
                self.view?.presentScene(game, transition: transition)
            }
        }
    }
}
 
struct GameView: View {
    let startScene = StartScene(fileNamed: "GameStartScene")!
    @State var selectedCharacter: String
    @Binding var isGame: Bool
    
    var body: some View {
        SpriteView(scene: startScene)
            //.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            .ignoresSafeArea()
            .onAppear {
                startScene.character = self.selectedCharacter
                startScene.isPresented = $isGame
            }
    }
}
