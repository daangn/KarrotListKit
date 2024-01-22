//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

public struct WillDisplayEvent: ListingViewEvent {
  public struct EventContext {
    public let indexPath: IndexPath
    public let anyComponent: AnyComponent
    public let content: UIView?
  }

  let handler: (EventContext) -> Void
}
