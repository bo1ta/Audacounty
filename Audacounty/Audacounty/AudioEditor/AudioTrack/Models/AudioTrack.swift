//
//  AudioTrack.swift
//  Audacounty
//
//  Created by Solomon Alexandru on 23.01.2025.
//

import Foundation

struct AudioTrack: Hashable {
  let id: UUID
  let url: URL
  let duration: Double

  init(id: UUID = UUID(), url: URL, duration: Double) {
    self.id = id
    self.url = url
    self.duration = duration
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func ==(_ lhs: AudioTrack, rhs: AudioTrack) -> Bool {
    lhs.id == rhs.id
  }
}
