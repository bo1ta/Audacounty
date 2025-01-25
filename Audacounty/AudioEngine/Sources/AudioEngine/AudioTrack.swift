//
//  AudioTrack.swift
//  Audacounty
//
//  Created by Solomon Alexandru on 23.01.2025.
//

import Foundation

public struct AudioTrack: Hashable, Identifiable {
  public let id: UUID
  public let url: URL
  public let duration: Double

  public init(id: UUID = UUID(), url: URL, duration: Double) {
    self.id = id
    self.url = url
    self.duration = duration
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  public static func ==(_ lhs: AudioTrack, rhs: AudioTrack) -> Bool {
    lhs.id == rhs.id
  }
}
