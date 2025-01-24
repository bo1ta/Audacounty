//
//  Container.swift
//  AudioEngine
//
//  Created by Solomon Alexandru on 24.01.2025.
//

import Factory

extension Container {
  public var audioEngine: Factory<AudioTrackEngine> {
    self { AudioTrackEngine() }
      .singleton
  }
}
