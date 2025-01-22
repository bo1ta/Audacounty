//
//  AudioEditorViewController.swift
//  Audacounty
//
//  Created by Solomon Alexandru on 21.01.2025.
//

import Foundation
import UIKit

class AudioEditorViewController: UIViewController {

  // MARK: Subviews

  private lazy var label: UILabel = {
    let label = UILabel()
    label.text = "Hello world"
    return label
  }()

  private let controlsStackView: UIStackView = {
    let stack = UIStackView()
    stack.axis = .horizontal
    stack.spacing = 12
    stack.distribution = .fillProportionally
    stack.alignment = .center
    stack.translatesAutoresizingMaskIntoConstraints = false
    return stack
  }()

  private let tracksCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumLineSpacing = 8
    layout.minimumInteritemSpacing = 0

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.backgroundColor = .systemBackground
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.alwaysBounceVertical = true
    return collectionView
  }()

  private lazy var playButton: UIButton = createControlButton(title: "Play", symbol: "play.fill")
  private lazy var pauseButton: UIButton = createControlButton(title: "Pause", symbol: "pause.fill")
  private lazy var stopButton: UIButton = createControlButton(title: "Stop", symbol: "stop.fill")
  private lazy var recordButton: UIButton = createControlButton(title: "Record", symbol: "record.circle")

  // MARK: Init

  private let audioFilePicker: AudioFilePicker
  private var pickedAudioURLs: [URL] = []

  init(audioFilePicker: AudioFilePicker = AudioFilePicker()) {
    self.audioFilePicker = audioFilePicker
    super.init(nibName: nil, bundle: nil)
    self.audioFilePicker.delegate = self
  }
  
  required init?(coder: NSCoder) {
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

    [playButton, pauseButton, stopButton, recordButton].forEach {
      controlsStackView.addArrangedSubview($0)
    }

    view.addSubview(controlsStackView)
    view.addSubview(tracksCollectionView)

    NSLayoutConstraint.activate([
      controlsStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
      controlsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      controlsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      controlsStackView.heightAnchor.constraint(equalToConstant: 44),

      tracksCollectionView.topAnchor.constraint(equalTo: controlsStackView.bottomAnchor, constant: 16),
      tracksCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tracksCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tracksCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }

  private func setupCollectionView() {
    tracksCollectionView.delegate = self
    tracksCollectionView.dataSource = self
    tracksCollectionView.register(AudioTrackCell.self, forCellWithReuseIdentifier: "AudioTrackCell")
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

  @objc private func showAudioFilePicker() {
    let controller = audioFilePicker.getViewController()
    present(controller, animated: true)
  }
}

// MARK: - AudioFilePickerDelegate

extension AudioEditorViewController: AudioFilePickerDelegate {
  func audioFilePicker(didPickAudioFilesAt urls: [URL]) {
    pickedAudioURLs = urls

    DispatchQueue.main.async {
      self.tracksCollectionView.reloadData()
    }
  }
}

// MARK: - UICollectionViewDelegate + UICollectionViewDataSource + UICollectionViewDelegateFlowLayout

extension AudioEditorViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return pickedAudioURLs.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AudioTrackCell", for: indexPath) as! AudioTrackCell

    if let url = pickedAudioURLs[safe: indexPath.item] {
      cell.updateWaveformForURL(url)
    }
    return cell
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.bounds.width, height: 100) // Adjust height as needed
  }
}
