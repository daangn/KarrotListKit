//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Foundation

/// Protocol defining the decision logic to trigger the next batch fetch.
public protocol NextBatchFetchDecisionProvider {

  /// Determines whether the next batch fetch should begin.
  ///
  /// - Returns: A Boolean value indicating whether the next batch fetch should start.
  func shouldBeginNextBatchFetch() -> Bool
}
