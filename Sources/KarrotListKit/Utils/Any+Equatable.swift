//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Foundation

extension Equatable {

  func isEqual(_ other: any Equatable) -> Bool {
    guard let other = other as? Self else {
      return other.isExactlyEqual(self)
    }
    return self == other
  }

  private func isExactlyEqual(_ other: any Equatable) -> Bool {
    guard let other = other as? Self else {
      return false
    }
    return self == other
  }
}
