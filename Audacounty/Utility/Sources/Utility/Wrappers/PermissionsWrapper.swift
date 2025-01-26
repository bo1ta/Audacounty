//
//  PermissionsWrapper.swift
//  Audacounty
//
//  Created by Solomon Alexandru on 22.01.2025.
//

import AVFoundation

public enum PermissionsWrapper {
  public static func requestRecordPermissions() async -> Bool {
    await AVAudioApplication.requestRecordPermission()
  }
}
