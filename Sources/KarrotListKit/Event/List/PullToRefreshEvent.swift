//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

/// This structure encapsulates the pull to refresh event information and contains a closure object for handling the pull to refresh event.
public struct PullToRefreshEvent: ListingViewEvent {
  public struct EventContext {}

  /// A closure that's called when the user pull to refresh content.
  let handler: (EventContext) -> Void
}

