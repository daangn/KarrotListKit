//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

/// Struct representing an event to trigger the next batch fetch in a listing view.
public struct NextBatchTriggerEvent: ListingViewEvent {

  /// Context for the NextBatchTriggerEvent.
  public struct EventContext {

    /// The context for the next batch operation.
    public let context: NextBatchContext
  }

  /// The decision provider to determine whether the next batch fetch should begin.
  let decisionProvider: NextBatchFetchDecisionProvider

  /// A closure that's called when the next batch fetch is triggered.
  let handler: (EventContext) -> Void
}
