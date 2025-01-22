//
//  DocumentPickerWrapper.swift
//  Audacounty
//
//  Created by Solomon Alexandru on 22.01.2025.
//

import Foundation
import UIKit
import AVFoundation

protocol AudioFilePickerDelegate: AnyObject {
  func audioFilePicker(didPickAudioFilesAt urls: [URL])
}

public class AudioFilePicker: NSObject, UIDocumentPickerDelegate {
  private static let documentContentTypes: [UTType] = [.aiff, .mp3, .mpeg4Audio]

  weak var delegate: AudioFilePickerDelegate?

  public func getViewController() -> UIDocumentPickerViewController {
    let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: Self.documentContentTypes, asCopy: true)
    documentPicker.delegate = self
    documentPicker.modalPresentationStyle = .overFullScreen
    return documentPicker
  }

  public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    delegate?.audioFilePicker(didPickAudioFilesAt: urls)
  }
}
