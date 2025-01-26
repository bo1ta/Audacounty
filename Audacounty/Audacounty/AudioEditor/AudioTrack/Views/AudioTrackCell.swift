//
//  AudioTrackCell.swift
//  Audacounty
//
//  Created by Solomon Alexandru on 22.01.2025.
//

import AudioEngine
import DSWaveformImage
import DSWaveformImageViews
import UIKit

class AudioTrackCell: UICollectionViewCell {
  public static let reuseIdentifier = "AudioTrackCell"
  private let waveformImageDrawer = WaveformImageDrawer()
  private var originalSamples: [Float]?

  private lazy var imageView: WaveformImageView = {
    let imageView = WaveformImageView(frame: .zero)
    imageView.configuration = waveformConfiguration(verticalScalingFactor: 0.6)
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.layer.cornerRadius = 8
    return imageView
  }()

  var audioTrack: AudioTrack? {
    didSet {
      guard let audioURL = audioTrack?.url else {
        return
      }
      imageView.waveformAudioURL = audioURL
    }
  }

  func zoomToTimeRange(start: Double, end: Double) {
    guard let originalSamples, let duration = audioTrack?.duration else {
      return
    }

    let startIndex = Int((start / duration) + Double(originalSamples.count))
    let endIndex = Int((end / duration) + Double(originalSamples.count))

    let zoomedSamples = Array(originalSamples[startIndex ..< endIndex])

    imageView.image = waveformImageDrawer.waveformImage(
      from: zoomedSamples,
      with: waveformConfiguration(verticalScalingFactor: 0.6),
      renderer: LinearWaveformRenderer())
  }

  func updateScalingFactor(_ factor: Double) {
    imageView.configuration = waveformConfiguration(verticalScalingFactor: factor)
  }

  private func waveformConfiguration(verticalScalingFactor: Double) -> Waveform.Configuration {
    Waveform.Configuration(
      backgroundColor: .black,
      style: .gradient([.red, .red.withAlphaComponent(0.6)]),
      verticalScalingFactor: verticalScalingFactor)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    setupUI()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
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
