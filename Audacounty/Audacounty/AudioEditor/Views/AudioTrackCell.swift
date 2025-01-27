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
  static let reuseIdentifier = "AudioTrackCell"
  private let waveformImageDrawer = WaveformImageDrawer()
  private var originalSamples: [Float]?

  private lazy var nameLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    label.textColor = .white
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private lazy var volumeSlider: UISlider = {
    let slider = UISlider()
    slider.minimumValue = 0.0
    slider.maximumValue = 1.0
    slider.value = 1.0
    slider.addTarget(self, action: #selector(volumeChanged(_:)), for: .valueChanged)
    slider.translatesAutoresizingMaskIntoConstraints = false
    return slider
  }()

  private lazy var controlsContainer: UIView = {
    let stack = UIView()
    stack.addSubview(nameLabel)
    stack.backgroundColor = .systemGray5
    stack.translatesAutoresizingMaskIntoConstraints = false
    return stack
  }()

  private lazy var imageView: WaveformImageView = {
    let imageView = WaveformImageView(frame: .zero)
    imageView.configuration = waveformConfiguration(verticalScalingFactor: 0.6)
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.layer.cornerRadius = 8
    return imageView
  }()

  var volumeChangeHandler: ((Float) -> Void)?

  var audioTrack: AudioTrack? {
    didSet {
      guard let audioTrack else {
        return
      }
      nameLabel.text = audioTrack.name
      volumeSlider.value = audioTrack.volume
      imageView.waveformAudioURL = audioTrack.url
    }
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
    contentView.addSubview(controlsContainer)
    contentView.addSubview(imageView)

    NSLayoutConstraint.activate([
      controlsContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
      controlsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
      controlsContainer.widthAnchor.constraint(equalToConstant: 60),
      controlsContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

      imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
      imageView.leadingAnchor.constraint(equalTo: controlsContainer.trailingAnchor),
      imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
      imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
    ])
  }

  @objc
  private func volumeChanged(_ sender: UISlider) {
    volumeChangeHandler?(sender.value)
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
}
