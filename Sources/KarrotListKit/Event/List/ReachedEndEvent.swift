//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Foundation

/// An event that triggers when the user scrolls to the end of a list view.
public struct ReachedEndEvent: ListingViewEvent {

  /// Context for the `ReachedEndEvent`.
  public struct EventContext {}

  /// Defines the offset from the end of the list view that will trigger the event.
  public enum OffsetFromEnd {
    /// Triggers the event when the user scrolls within a multiple of the height of the content view.
    case relativeToContainerSize(multiplier: CGFloat)
    /// Triggers the event when the user scrolls within an absolute point value from the end.
    case absolute(CGFloat)
  }

  /// The offset from the end of the list view that will trigger the event.
  let offset: OffsetFromEnd
  /// The handler that will be called when the event is triggered.
  let handler: (EventContext) -> Void
}
