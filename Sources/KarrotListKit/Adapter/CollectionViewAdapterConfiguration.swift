//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Foundation

public struct CollectionViewAdapterConfiguration {
  public let pullToRefreshEnabled: Bool

  public let batchUpdateInterruptCount: Int

  public init(
    pullToRefreshEnabled: Bool = false,
    batchUpdateInterruptCount: Int = 100
  ) {
    self.pullToRefreshEnabled = pullToRefreshEnabled
    self.batchUpdateInterruptCount = batchUpdateInterruptCount
  }
}
