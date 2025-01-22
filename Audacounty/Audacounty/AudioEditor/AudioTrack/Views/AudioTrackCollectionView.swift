//
//  AudioTrackCollectionView.swift
//  Audacounty
//
//  Created by Solomon Alexandru on 22.01.2025.
//

import UIKit
import Combine

class AudioTrackCollectionView: UICollectionView {
  enum Event {
    case onUpdateTimeSelection(start: Double, end: Double)
  }

  private var selectionOverlay: SelectionOverlayView?
  private var timeScale: Double = 44100.0 // samples per point
  private let eventSubject = PassthroughSubject<Event, Never>()

  public var eventPublisher: AnyPublisher<Event, Never> {
    eventSubject.eraseToAnyPublisher()
  }

  private func setupSelectionGesture() {
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
    addGestureRecognizer(panGesture)

    selectionOverlay = SelectionOverlayView()
    selectionOverlay?.backgroundColor = .clear
    selectionOverlay?.isUserInteractionEnabled = false
    selectionOverlay?.translatesAutoresizingMaskIntoConstraints = false

    if let overlay = selectionOverlay {
      addSubview(overlay)

      NSLayoutConstraint.activate([
        overlay.topAnchor.constraint(equalTo: topAnchor),
        overlay.bottomAnchor.constraint(equalTo: bottomAnchor),
        overlay.leadingAnchor.constraint(equalTo: leadingAnchor),
        overlay.trailingAnchor.constraint(equalTo: trailingAnchor)
      ])
    }
  }

  @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
    let point = gesture.location(in: self)

    switch gesture.state {
    case .began:
      selectionOverlay?.updateSelection(start: point, end: point)
    case .changed:
      selectionOverlay?.updateSelection(start: selectionOverlay?.startPoint, end: point)

      // Convert point to time
      let startTime = (selectionOverlay?.startPoint?.x ?? 0) * timeScale
      let endTime = point.x * timeScale

      eventSubject.send(.onUpdateTimeSelection(start: startTime, end: endTime))

    case .ended:
      // Finalize selection
      break
    default:
      break
    }
  }
}
