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
  private var playerNodes: [AudioTrack.ID: AVAudioPlayerNode] = [:]
  private var audioTracks: [AudioTrack] = []

  public func addTrack(_ track: AudioTrack) {
    guard let audioFile = try? AVAudioFile(forReading: track.url) else {
      Logger.error(AudioTrackEngineError.failedToReadAudioFile, message: "Error reading audio file")
      return
    }

    let playerNode = AVAudioPlayerNode()
    audioEngine.attach(playerNode)
    audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: audioFile.processingFormat)

    playerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)

    playerNodes[track.id] = playerNode
    audioTracks.append(track)
  }

  public func play() {
    do {
      try audioEngine.start()
      for (_, playerNode) in playerNodes {
        playerNode.play()
      }
    } catch {
      Logger.error(error, message: "Could not start audio engine")
    }
  }

  public func stop() {
    for (trackID, playerNode) in playerNodes {
      playerNode.stop()

      scheduleAudioTrackID(trackID, forPlayerNode: playerNode)
    }
    audioEngine.stop()
  }

  private func scheduleAudioTrackID(_ trackID: AudioTrack.ID, forPlayerNode playerNode: AVAudioPlayerNode) {
    guard let audioTrack = audioTracks.first(where: { $0.id == trackID }) else {
      Logger.error(AudioTrackEngineError.unexpectedNil, message: "No audio track found for given ID")
      return
    }
    do {
      let audioFile = try AVAudioFile(forReading: audioTrack.url)
      playerNode.scheduleFile(audioFile, at: nil)
    } catch {
      Logger.error(error, message: "Cannot schedule audio track")
    }
  }

  public func getTotalDuration() -> TimeInterval? {
    guard audioTracks.count > 1 else {
      return audioTracks.first?.duration
    }
    return audioTracks.max(by: { $0.duration < $1.duration })?.duration
  }

  public func getCurrentTime() -> TimeInterval? {
    guard
      let (trackID, firstPlayerNode) = playerNodes.first,
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
