//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

public struct CollectionViewAdapterConfiguration {
  public let pullToRefreshEnabled: Bool

  public let batchUpdateInterruptCount: Int

  public let refreshControlTintColor: UIColor?

  public init(
    pullToRefreshEnabled: Bool = false,
    batchUpdateInterruptCount: Int = 100,
    refreshControlTintColor: UIColor? = nil
  ) {
    self.pullToRefreshEnabled = pullToRefreshEnabled
    self.batchUpdateInterruptCount = batchUpdateInterruptCount
    self.refreshControlTintColor = refreshControlTintColor
  }
}
