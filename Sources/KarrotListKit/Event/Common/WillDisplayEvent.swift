//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

/// This structure encapsulates the willDisplayEvent event information and contains a closure object for handling the willDisplayEvent event.
public struct WillDisplayEvent: ListingViewEvent {
  public struct EventContext {

    /// The index path of view that being added.
    public let indexPath: IndexPath

    /// The component owned by the view that being added.
    public let anyComponent: AnyComponent

    /// The content owned by the view that being added.
    public let content: UIView?
  }

  /// A closure that's called when the view being added
  let handler: (EventContext) -> Void
}
