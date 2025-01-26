//
//  Container+Extension.swift
//  Utility
//
//  Created by Solomon Alexandru on 26.01.2025.
//

import Factory

extension Container {
  public var audioFilePicker: Factory<AudioFilePicker> {
    self { AudioFilePicker() }
  }
}
