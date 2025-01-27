//
//  TrackPlayer.swift
//  AudioEngine
//
//  Created by Solomon Alexandru on 28.01.2025.
//

import AVFoundation

final class TrackPlayer {
  let playerNode: AVAudioPlayerNode
  let audioFile: AVAudioFile
  let audioTrack: AudioTrack

  var volume: Float {
    didSet {
      playerNode.volume = volume
    }
  }

  init(audioTrack: AudioTrack, audioFile: AVAudioFile) {
    self.playerNode = AVAudioPlayerNode()
    self.audioTrack = audioTrack
    self.volume = audioTrack.volume
    self.audioFile = audioFile
  }

  func schedule() {
    playerNode.scheduleFile(audioFile, at: nil)
  }

  func play(atTime time: AVAudioTime? = nil) {
    playerNode.play(at: time)
  }

  func stop() {
    playerNode.stop()
  }
}
