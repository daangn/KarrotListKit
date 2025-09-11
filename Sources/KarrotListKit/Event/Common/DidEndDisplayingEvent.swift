//
//  Copyright (c) 2024 Danggeun Market Inc.
//

#if canImport(UIKit)
import UIKit

/// This structure encapsulates the didEndDisplaying event information and contains a closure object for handling the didEndDisplaying event.
public struct DidEndDisplayingEvent: ListingViewEvent {
  public struct EventContext {

    /// The index path of the view that was removed.
    public let indexPath: IndexPath

    /// The component owned by the view that was removed.
    public let anyComponent: AnyComponent

    /// The content owned by the view that was removed.
    public let content: UIView?
  }

  /// A closure that's called when the view was removed.
  let handler: (EventContext) -> Void
}
#endif
