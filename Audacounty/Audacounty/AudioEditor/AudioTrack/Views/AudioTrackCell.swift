//
//  AudioTrackCell.swift
//  Audacounty
//
//  Created by Solomon Alexandru on 22.01.2025.
//

import UIKit
import DSWaveformImage
import DSWaveformImageViews

class AudioTrackCell: UICollectionViewCell {
  public static let reuseIdentifier = "AudioTrackCell"

  private let waveformImageDrawer = WaveformImageDrawer()

  private let imageView: WaveformImageView = {
    let imageView = WaveformImageView(frame: .zero)
    imageView.configuration = Waveform.Configuration(backgroundColor: .black, style: .gradient([.red, .red.withAlphaComponent(0.6)]), verticalScalingFactor: 0.6)
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.layer.cornerRadius = 8
    return imageView
  }()

  var audioTrack: AudioTrack? {
    didSet {
      if let audioURL = audioTrack?.url {
        imageView.waveformAudioURL = audioURL
      }
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupUI() {
    contentView.addSubview(imageView)

    NSLayoutConstraint.activate([
      imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
      imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
      imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
      imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
    ])
  }
}

