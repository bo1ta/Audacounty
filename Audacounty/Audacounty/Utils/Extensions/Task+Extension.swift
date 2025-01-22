//
//  Task+Extension.swift
//  Audacounty
//
//  Created by Solomon Alexandru on 22.01.2025.
//

import Combine

extension Task {
  func store(in set: inout Set<AnyCancellable>) {
    set.insert(AnyCancellable(cancel))
  }
}
