//
//  SelectionOverlayView.swift
//  Audacounty
//
//  Created by Solomon Alexandru on 22.01.2025.
//

import UIKit

class SelectionOverlayView: UIView {
  var startPoint: CGPoint?
  var endPoint: CGPoint?

  override func draw(_: CGRect) {
    guard let start = startPoint, let end = endPoint else { return }

    let selectionPath = UIBezierPath(rect: CGRect(
      x: min(start.x, end.x),
      y: 0,
      width: abs(end.x - start.x),
      height: bounds.height))

    UIColor.systemBlue.withAlphaComponent(0.3).setFill()
    selectionPath.fill()
  }

  func updateSelection(start: CGPoint?, end: CGPoint?) {
    startPoint = start
    endPoint = end
    setNeedsDisplay()
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    setNeedsDisplay()
  }
}
