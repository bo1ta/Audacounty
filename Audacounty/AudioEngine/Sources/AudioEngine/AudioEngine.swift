//
//  AudioTrackEngine.swift
//  AudioEngine
//
//  Created by Solomon Alexandru on 22.01.2025.
//

import AVFoundation
import Utility

public class AudioTrackEngine {
  private let audioEngine = AVAudioEngine()
  private var playerNodes: [AVAudioPlayerNode] = []

  public func addTrackURL(_ trackURL: URL) {
    guard let audioFile = try? AVAudioFile(forReading: trackURL) else {
      Logger.error(AudioTrackEngineError.failedToReadAudioFile, message: "Error reading audio file")
      return
    }

    let playerNode = AVAudioPlayerNode()
    audioEngine.attach(playerNode)
    audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: audioFile.processingFormat)

    playerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)

    playerNodes.append(playerNode)
  }

  public func play() {
    do {
      try audioEngine.start()
      playerNodes.forEach { $0.play() }
    } catch {
      Logger.error(error, message: "Could not start audio engine")
    }
  }

  public func stop() {
    playerNodes.forEach { $0.stop() }
    audioEngine.stop()
  }
}

enum AudioTrackEngineError: Error {
  case failedToReadAudioFile
}
