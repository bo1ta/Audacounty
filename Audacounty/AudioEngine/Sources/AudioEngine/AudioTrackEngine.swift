//
//  AudioTrackEngine.swift
//  AudioEngine
//
//  Created by Solomon Alexandru on 22.01.2025.
//

import AVFoundation
import Utility

// MARK: - AudioTrackEngine

public class AudioTrackEngine {
  private let audioEngine = AVAudioEngine()
  private var trackPlayers: [TrackPlayer] = []

  public func addTrack(_ track: AudioTrack) {
    guard let audioFile = try? AVAudioFile(forReading: track.url) else {
      Logger.error(AudioTrackEngineError.failedToReadAudioFile, message: "Error reading audio file")
      return
    }

    let trackPlayer = TrackPlayer(audioTrack: track, audioFile: audioFile)
    audioEngine.attach(trackPlayer.playerNode)
    audioEngine.connect(trackPlayer.playerNode, to: audioEngine.mainMixerNode, format: audioFile.processingFormat)

    trackPlayer.schedule()
    trackPlayers.append(trackPlayer)
  }

  public func removeTrack(withID trackID: AudioTrack.ID) {
    guard let index = trackPlayers.firstIndex(where: { $0.audioTrack.id == trackID }) else {
      Logger.error(AudioTrackEngineError.unexpectedNil, message: "No track player found for given ID")
      return
    }

    let trackPlayer = trackPlayers[index]
    trackPlayer.playerNode.stop()
    audioEngine.detach(trackPlayer.playerNode)
    trackPlayers.remove(at: index)
  }

  public func play() {
    do {
      try audioEngine.start()
      for trackPlayer in trackPlayers {
        trackPlayer.play()
      }
    } catch {
      Logger.error(error, message: "Could not start audio engine")
    }
  }

  public func setVolume(_ volume: Float, forTrackID trackID: AudioTrack.ID) {
    guard let trackPlayer = trackPlayers.first(where: { $0.audioTrack.id == trackID }) else {
      Logger.error(AudioTrackEngineError.unexpectedNil, message: "No track player found fro given ID")
      return
    }

    trackPlayer.volume = volume
  }

  public func stop() {
    for trackPlayer in trackPlayers {
      trackPlayer.stop()
      trackPlayer.schedule()
    }

    audioEngine.stop()
  }

  public func getTotalDuration() -> TimeInterval? {
    let durations = trackPlayers.map { $0.audioTrack.duration }
    return durations.max()
  }

  public func getCurrentTime() -> TimeInterval? {
    guard
      let firstPlayerNode = trackPlayers.first?.playerNode,
      let lastRenderTime = firstPlayerNode.lastRenderTime,
      let playerTime = firstPlayerNode.playerTime(forNodeTime: lastRenderTime)
    else {
      Logger.error(AudioTrackEngineError.failedToRetrieveCurrentTime, message: "Could not retrieve current time")
      return nil
    }

    return Double(playerTime.sampleTime) / playerTime.sampleRate
  }
}

// MARK: - AudioTrackEngineError

enum AudioTrackEngineError: Error {
  case unexpectedNil
  case failedToReadAudioFile
  case failedToRetrieveCurrentTime
}
