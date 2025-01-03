//
//  AudioPlayer.swift
//  Focus
//
//  Created by Husein Hakim on 26/12/24.
//

import Foundation
import AVFoundation

class AudioPlayer: ObservableObject {
    private var player: AVAudioPlayer?
    
    func playSound(fileName: String, fileType: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileType) else {
            print("Sound file not found")
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1 // Loop indefinitely
            player?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
    
    func stopSound() {
        player?.stop()
    }
}

