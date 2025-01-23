//
//  AudioTrackCollectionView.swift
//  Audacounty
//
//  Created by Solomon Alexandru on 22.01.2025.
//

import UIKit

protocol AudioTrackCollectionViewDelegate: AnyObject {
  func audioTrackCollectionView(_ collectionView: AudioTrackCollectionView, didSelectTimeRange start: Double, end: Double)
}

class AudioTrackCollectionView: UICollectionView {
  public weak var selectionDelegate: AudioTrackCollectionViewDelegate?

  private var timeScale: Double = 44100.0 // samples per point

  private lazy var selectionOverlay: SelectionOverlayView = {
    let selectionOverlay = SelectionOverlayView(frame: .zero)
    selectionOverlay.backgroundColor = .clear
    selectionOverlay.isUserInteractionEnabled = false
    selectionOverlay.translatesAutoresizingMaskIntoConstraints = false
    return selectionOverlay
  }()

  func setupUI() {
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
    addGestureRecognizer(panGesture)

    superview?.addSubview(selectionOverlay)
    superview?.bringSubviewToFront(selectionOverlay)

    NSLayoutConstraint.activate([
      selectionOverlay.topAnchor.constraint(equalTo: topAnchor),
      selectionOverlay.bottomAnchor.constraint(equalTo: bottomAnchor),
      selectionOverlay.leadingAnchor.constraint(equalTo: leadingAnchor),
      selectionOverlay.trailingAnchor.constraint(equalTo: trailingAnchor)
    ])
  }

  @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
    let point = gesture.location(in: self)

    switch gesture.state {
    case .began:
      selectionOverlay.updateSelection(start: point, end: point)
    case .changed:
      selectionOverlay.updateSelection(start: selectionOverlay.startPoint, end: point)

      // Convert point to time
      let startTime = (selectionOverlay.startPoint?.x ?? 0) * timeScale
      let endTime = point.x * timeScale

      selectionDelegate?.audioTrackCollectionView(self, didSelectTimeRange: startTime, end: endTime)

    case .ended:
      // Finalize selection
      break
    default:
      break
    }
  }
}
