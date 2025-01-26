//
//  AudioTrackCollectionView.swift
//  Audacounty
//
//  Created by Solomon Alexandru on 22.01.2025.
//

import UIKit

// MARK: - AudioTrackCollectionViewDelegate

protocol AudioTrackCollectionViewDelegate: AnyObject {
  func audioTrackCollectionView(_ collectionView: AudioTrackCollectionView, didSelectTimeRange start: Double, end: Double)
}

// MARK: - AudioTrackCollectionView

class AudioTrackCollectionView: UICollectionView {
  public weak var selectionDelegate: AudioTrackCollectionViewDelegate?

  private var timeScale = 44100.0 // samples per point

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

    let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
    addGestureRecognizer(pinchGesture)

    superview?.addSubview(selectionOverlay)
    superview?.bringSubviewToFront(selectionOverlay)

    NSLayoutConstraint.activate([
      selectionOverlay.topAnchor.constraint(equalTo: topAnchor),
      selectionOverlay.bottomAnchor.constraint(equalTo: bottomAnchor),
      selectionOverlay.leadingAnchor.constraint(equalTo: leadingAnchor),
      selectionOverlay.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])
  }

  @objc
  private func handlePan(_ gesture: UIPanGestureRecognizer) {
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

  @objc
  private func handlePinch(_: UIPinchGestureRecognizer) {
//    guard gesture.state == .changed else { return }
//
//    let currentStartTime: Double =
//    let currentEndTime: Double =
//    let totalDuration: Double =
//
//    // Calculate new time range based on pinch
//    let center = gesture.location(in: self)
//    let centerTimeRatio = center.x / bounds.width
//
//    let currentTimeRange = currentEndTime - currentStartTime
//    let newTimeRange = currentTimeRange / gesture.scale
//
//    let newStartTime = max(0, currentStartTime +
//        (currentTimeRange - newTimeRange) * centerTimeRatio)
//    let newEndTime = min(totalDuration, newStartTime + newTimeRange)
//
//    // Update cells with new time range
//    for cell in visibleCells {
//        if let audioTrackCell = cell as? AudioTrackCell {
//            audioTrackCell.zoomToTimeRange(start: newStartTime, end: newEndTime)
//        }
//    }
//
//    gesture.scale = 1.0
  }
}
