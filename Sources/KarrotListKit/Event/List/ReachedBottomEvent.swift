//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Foundation

/// An event that triggers when the user scrolls to the bottom of a list view.
public struct ReachedBottomEvent: ListingViewEvent {

  /// Context for the `ReachedBottomEvent`.
  public struct EventContext {}

  /// Defines the offset from the bottom of the list view that will trigger the event.
  public enum OffsetFromBottom {
    /// Triggers the event when the user scrolls within a multiple of the height of the content view.
    case multipleHeight(CGFloat)
    /// Triggers the event when the user scrolls within an absolute point value from the bottom.
    case absolute(CGFloat)
  }

  /// The offset from the bottom of the list view that will trigger the event.
  let offset: OffsetFromBottom
  /// The handler that will be called when the event is triggered.
  let handler: (EventContext) -> Void
}
