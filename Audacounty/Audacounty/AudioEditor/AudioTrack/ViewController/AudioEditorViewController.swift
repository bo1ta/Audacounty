//
//  AudioEditorViewController.swift
//  Audacounty
//
//  Created by Solomon Alexandru on 21.01.2025.
//

import AVFoundation
import Foundation
import UIKit
import Utility

// MARK: - AudioEditorViewController

class AudioEditorViewController: UIViewController {
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

  private lazy var playButton: UIButton = createControlButton(title: "Play", symbol: "play.fill")
  private lazy var pauseButton: UIButton = createControlButton(title: "Pause", symbol: "pause.fill")
  private lazy var stopButton: UIButton = createControlButton(title: "Stop", symbol: "stop.fill")
  private lazy var recordButton: UIButton = createControlButton(title: "Record", symbol: "record.circle")

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

  private let audioFilePicker: AudioFilePicker
  private var audioTracks: [AudioTrack] = []

  init(audioFilePicker: AudioFilePicker = AudioFilePicker()) {
    self.audioFilePicker = audioFilePicker

    super.init(nibName: nil, bundle: nil)

    self.audioFilePicker.delegate = self
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

    for item in [playButton, pauseButton, stopButton, recordButton] {
      controlsStackView.addArrangedSubview(item)
    }

    view.addSubview(controlsStackView)
    view.addSubview(tracksCollectionView)
    tracksCollectionView.setupUI()

    NSLayoutConstraint.activate([
      controlsStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
      controlsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      controlsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      controlsStackView.heightAnchor.constraint(equalToConstant: 44),

      tracksCollectionView.topAnchor.constraint(equalTo: controlsStackView.bottomAnchor, constant: 16),
      tracksCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tracksCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tracksCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }

  private func setupCollectionView() {
    tracksCollectionView.delegate = self
    tracksCollectionView.dataSource = dataSource
    tracksCollectionView.selectionDelegate = self
    tracksCollectionView.register(AudioTrackCell.self, forCellWithReuseIdentifier: AudioTrackCell.reuseIdentifier)
  }

  private func createControlButton(title: String, symbol: String) -> UIButton {
    let button = UIButton(type: .system)
    var configuration = UIButton.Configuration.filled()
    configuration.image = UIImage(systemName: symbol)
    configuration.imagePadding = 8
    configuration.title = title
    button.configuration = configuration

    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showAudioFilePicker))
    button.addGestureRecognizer(gestureRecognizer)
    return button
  }

  @objc
  private func showAudioFilePicker() {
    let controller = audioFilePicker.getViewController()
    present(controller, animated: true)
  }
}

// MARK: AudioFilePickerDelegate

extension AudioEditorViewController: AudioFilePickerDelegate {
  func audioFilePicker(didPickAudioFilesAt urls: [URL]) {
    let pickedAudioTracks = urls.compactMap { createAudioTrack(from: $0) }
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
