//
//  AudioTrack.swift
//  Audacounty
//
//  Created by Solomon Alexandru on 23.01.2025.
//

import Foundation

public struct AudioTrack: Hashable, Identifiable, Sendable {
  public let id: UUID
  public let url: URL
  public let duration: Double
  public let name: String
  public var volume: Float // ranges from 0.0 to 1.0

  public init(id: UUID = UUID(), url: URL, duration: Double, name: String = "", volume: Float = 1.0) {
    self.id = id
    self.url = url
    self.duration = duration
    self.name = name
    self.volume = volume
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  public static func ==(_ lhs: AudioTrack, rhs: AudioTrack) -> Bool {
    lhs.id == rhs.id
  }
}
