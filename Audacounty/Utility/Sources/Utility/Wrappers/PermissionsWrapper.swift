//
//  PermissionsWrapper.swift
//  Audacounty
//
//  Created by Solomon Alexandru on 22.01.2025.
//

import AVFoundation

public struct PermissionsWrapper {
  public func requestRecordPermissions() async -> Bool {
    await AVAudioApplication.requestRecordPermission()
  }
}
