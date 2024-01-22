//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

public struct PullToRefreshEvent: ListingViewEvent {
  public struct EventContext {}

  let handler: (EventContext) -> Void
}

