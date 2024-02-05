//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

public struct CollectionViewAdapterConfiguration {

  public let refreshControl: RefreshControl
  public let batchUpdateInterruptCount: Int

  public init(
    refreshControl: RefreshControl = .disabled(),
    batchUpdateInterruptCount: Int = 100
  ) {
    self.refreshControl = refreshControl
    self.batchUpdateInterruptCount = batchUpdateInterruptCount
  }
}


// MARK: - RefreshControl

extension CollectionViewAdapterConfiguration {

  public struct RefreshControl {

    public let isEnabled: Bool
    public let tintColor: UIColor

    public static func enabled(tintColor: UIColor) -> RefreshControl {
      .init(isEnabled: true, tintColor: tintColor)
    }

    public static func disabled() -> RefreshControl {
      .init(isEnabled: false, tintColor: .clear)
    }
  }
}
