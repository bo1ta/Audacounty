//
//  AudioFilePicker.swift
//  Audacounty
//
//  Created by Solomon Alexandru on 22.01.2025.
//

import AVFoundation
import Foundation
import SwiftUI
import UIKit

// MARK: - AudioFilePickerDelegate

public protocol AudioFilePickerDelegate: AnyObject {
  func audioFilePicker(didPickAudioFilesAt urls: [URL])
}

// MARK: - AudioFilePicker

public class AudioFilePicker: NSObject, UIDocumentPickerDelegate {
  private static let documentContentTypes: [UTType] = [.aiff, .mp3, .mpeg4Audio]

  public weak var delegate: AudioFilePickerDelegate?

  /// overriding just to make it nonisolated, so the compiler doesn't complain when initialising it in `Factory.Container`
  ///
  nonisolated override public init() {
    super.init()
  }

  public func getViewController() -> UIDocumentPickerViewController {
    let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: Self.documentContentTypes, asCopy: true)
    documentPicker.delegate = self
    documentPicker.modalPresentationStyle = .overFullScreen
    documentPicker.allowsMultipleSelection = true
    return documentPicker
  }

  public func documentPicker(_: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    delegate?.audioFilePicker(didPickAudioFilesAt: urls)
  }
}
