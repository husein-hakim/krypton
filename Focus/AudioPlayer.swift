//
//  AudioPlayer.swift
//  Focus
//
//  Created by Husein Hakim on 26/12/24.
//

import Foundation
import AVFoundation

class AudioPlayer: ObservableObject {
    private var players: [String: AVAudioPlayer] = [:]
    @Published var volume: Float = 0.5 {
        didSet {
            updateVolumeForAllPlayers()
        }
    }
    
    /// Preloads the audio file into memory to avoid delays during playback.
    func preloadAudio(fileName: String, fileType: String) {
        let key = "\(fileName).\(fileType)"
        guard players[key] == nil else { return } // Skip if already preloaded
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileType) else {
            print("Sound file not found")
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            players[key] = player
        } catch {
            print("Error loading audio file: \(error.localizedDescription)")
        }
    }
    
    /// Plays the preloaded audio file once.
    func playSoundOnce(fileName: String, fileType: String) {
        let key = "\(fileName).\(fileType)"
        
        if let player = players[key] {
            player.stop() // Reset playback
            player.currentTime = 0
            player.play()
        } else {
            //preloadAudio(fileName: fileName, fileType: fileType)
            players[key]?.play()
        }
    }
    
    /// Loops the preloaded audio file indefinitely.
    func playSound(fileName: String, fileType: String) {
        let key = "\(fileName).\(fileType)"
        
        if let player = players[key] {
            player.numberOfLoops = -1
            player.stop() // Reset playback
            player.currentTime = 0
            player.volume = volume
            player.play()
        } else {
            preloadAudio(fileName: fileName, fileType: fileType)
            if let player = players[key] {
                player.numberOfLoops = -1
                player.play()
            }
        }
    }
    
    /// Stops playback of the specified audio file.
    func stopSound(fileName: String, fileType: String) {
        let key = "\(fileName).\(fileType)"
        players[key]?.stop()
    }
    
    /// Stops all currently playing sounds.
    func stopAllSounds() {
        for player in players.values {
            player.stop()
        }
    }
    
    private func updateVolumeForAllPlayers() {
        for player in players.values {
            player.volume = volume
        }
    }
}


