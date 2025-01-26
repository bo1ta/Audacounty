//
//  AudioEditorViewController.swift
//  Audacounty
//
//  Created by Solomon Alexandru on 21.01.2025.
//

import AudioEngine
import AVFoundation
import Factory
import Foundation
import UIKit
import Utility

// MARK: - AudioEditorViewController

class AudioEditorViewController: UIViewController {
  @Injected(\.audioEngine) private var audioEngine: AudioTrackEngine
  @Injected(\.audioFilePicker) private var filePicker: AudioFilePicker

  // MARK: Subviews

  private let controlsStackView: UIStackView = {
    let stack = UIStackView()
    stack.axis = .horizontal
    stack.spacing = 12
    stack.distribution = .fillProportionally
    stack.alignment = .center
    stack.translatesAutoresizingMaskIntoConstraints = false
    return stack
  }()

  private let tracksCollectionView: AudioTrackCollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumLineSpacing = 8
    layout.minimumInteritemSpacing = 0

    let collectionView = AudioTrackCollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.backgroundColor = .systemBackground
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.alwaysBounceVertical = true
    return collectionView
  }()

  private let progressLabel: UILabel = {
    let label = UILabel()
    label.text = "00:00"
    label.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .regular)
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private lazy var playheadView: UIView = {
    let view = UIView()
    view.backgroundColor = .red
    view.translatesAutoresizingMaskIntoConstraints = false
    view.alpha = 0.5
    view.layer.zPosition = 100
    view.isHidden = true
    return view
  }()

  private lazy var playButton = createControlButton(title: "Play", symbol: "play.fill", action: #selector(playAction))
  private lazy var pauseButton = createControlButton(title: "Pause", symbol: "pause.fill", action: #selector(pauseAction))
  private lazy var stopButton = createControlButton(title: "Stop", symbol: "stop.fill", action: #selector(stopAction))
  private lazy var recordButton = createControlButton(title: "Record", symbol: "record.circle", action: #selector(recordAction))

  // MARK: DataSource

  enum Section {
    case main
  }

  typealias DataSource = UICollectionViewDiffableDataSource<Section, AudioTrack>
  typealias Snapshot = NSDiffableDataSourceSnapshot<Section, AudioTrack>

  private lazy var dataSource = DataSource(collectionView: tracksCollectionView) { collectionView, indexPath, _ in
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: AudioTrackCell.reuseIdentifier,
      for: indexPath) as? AudioTrackCell
    if let audioTrack = self.audioTracks[safe: indexPath.item] {
      cell?.audioTrack = audioTrack
    }
    return cell
  }

  // MARK: Init

  private var audioTracks: [AudioTrack] = []
  private var playbackTimer: Timer?
  private var playheadLeadingConstraint: NSLayoutConstraint?

  init() {
    super.init(nibName: nil, bundle: nil)

    filePicker.delegate = self
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    setupUI()
    setupCollectionView()
  }

  // MARK: UI Setup

  private func setupUI() {
    view.backgroundColor = .systemBackground

    controlsStackView.addArrangedSubview(progressLabel)

    for item in [playButton, pauseButton, stopButton, recordButton] {
      controlsStackView.addArrangedSubview(item)
    }

    view.addSubview(controlsStackView)
    view.addSubview(tracksCollectionView)
    tracksCollectionView.setupUI()

    view.addSubview(playheadView)

    playheadLeadingConstraint = playheadView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
    playheadLeadingConstraint?.isActive = true

    NSLayoutConstraint.activate([
      controlsStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
      controlsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      controlsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      controlsStackView.heightAnchor.constraint(equalToConstant: 44),

      tracksCollectionView.topAnchor.constraint(equalTo: controlsStackView.bottomAnchor, constant: 16),
      tracksCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tracksCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tracksCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

      playheadView.widthAnchor.constraint(equalToConstant: 2),
      playheadView.topAnchor.constraint(equalTo: tracksCollectionView.topAnchor),
      playheadView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }

  private func setupCollectionView() {
    tracksCollectionView.delegate = self
    tracksCollectionView.dataSource = dataSource
    tracksCollectionView.selectionDelegate = self
    tracksCollectionView.register(AudioTrackCell.self, forCellWithReuseIdentifier: AudioTrackCell.reuseIdentifier)
  }

  private func createControlButton(title _: String, symbol: String, action: Selector) -> UIButton {
    let button = UIButton(type: .system)
    var configuration = UIButton.Configuration.filled()
    configuration.image = UIImage(systemName: symbol)
    configuration.imagePadding = 8
    button.configuration = configuration

    let gestureRecognizer = UITapGestureRecognizer(target: self, action: action)
    button.addGestureRecognizer(gestureRecognizer)
    return button
  }

  @objc
  private func playAction() {
    audioEngine.play()
    schedulePlaybackTimer()
    playheadView.isHidden = false
  }

  private func updateProgressLabel() {
    assert(Thread.isMainThread, "Should update UI on the main thread")

    guard
      let currentTime = audioEngine.getCurrentTime(),
      let totalDuration = audioEngine.getTotalDuration()
    else {
      playbackTimer?.invalidate()
      playbackTimer = nil
      playheadView.isHidden = true
      return
    }

    /// Update progress text
    let minutes = Int(currentTime / 60)
    let seconds = Int(currentTime.truncatingRemainder(dividingBy: 60))
    let timeString = String(format: "%02d:%02d", minutes, seconds)
    progressLabel.text = timeString

    /// Update progress bar
    let progress = CGFloat(currentTime / totalDuration)
    playheadLeadingConstraint?.constant = view.bounds.width * progress
  }

  @objc
  private func pauseAction() {
    showAudioFilePicker()
  }

  @objc
  private func stopAction() {
    audioEngine.stop()
    resetPlaybackTimer()
  }

  private func schedulePlaybackTimer() {
    playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
      self?.updateProgressLabel()
    }
    if let playbackTimer {
      RunLoop.main.add(playbackTimer, forMode: .common)
    }
  }

  private func resetPlaybackTimer() {
    playbackTimer?.invalidate()
    playbackTimer = nil
  }

  @objc
  private func recordAction() { }

  @objc
  private func showAudioFilePicker() {
    let controller = filePicker.getViewController()
    present(controller, animated: true)
  }
}

// MARK: AudioFilePickerDelegate

extension AudioEditorViewController: AudioFilePickerDelegate {
  func audioFilePicker(didPickAudioFilesAt urls: [URL]) {
    let pickedAudioTracks = urls.compactMap { createAudioTrack(from: $0) }
    for track in pickedAudioTracks {
      audioEngine.addTrack(track)
    }

    audioTracks.append(contentsOf: pickedAudioTracks)
    applySnapshot()
  }

  private func createAudioTrack(from url: URL) -> AudioTrack? {
    do {
      let assetReader = try AVAssetReader(asset: AVURLAsset(url: url))
      let duration = assetReader.asset.duration.seconds
      return AudioTrack(url: url, duration: duration)
    } catch {
      print("Failed to create audio track for url: \(url): \(error.localizedDescription)")
      return nil
    }
  }

  private func applySnapshot(animating: Bool = true) {
    var snapshot = Snapshot()
    snapshot.appendSections([.main])
    snapshot.appendItems(audioTracks)
    dataSource.apply(snapshot, animatingDifferences: animating)
  }
}

// MARK: AudioTrackCollectionViewDelegate

extension AudioEditorViewController: AudioTrackCollectionViewDelegate {
  func audioTrackCollectionView(_: AudioTrackCollectionView, didSelectTimeRange start: Double, end: Double) {
    print("START: \(start) and FINISH: \(end)")
  }
}

// MARK: UICollectionViewDelegateFlowLayout

extension AudioEditorViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(
    _ collectionView: UICollectionView,
    layout _: UICollectionViewLayout,
    sizeForItemAt _: IndexPath)
    -> CGSize
  {
    CGSize(width: collectionView.bounds.width, height: 100)
  }
}
