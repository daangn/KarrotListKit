//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Foundation

public struct DidSelectEvent: ListingViewEvent {
  public struct EventContext {
    public let indexPath: IndexPath
    public let anyComponent: AnyComponent
  }

  let handler: (EventContext) -> Void
}
