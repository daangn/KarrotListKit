//
//  Copyright (c) 2024 Danggeun Market Inc.
//

#if canImport(UIKit)
import UIKit

/// This structure encapsulates the highlight event information and contains a closure object for handling the highlight event.
public struct HighlightEvent: ListingViewEvent {

  public struct EventContext {

    /// The index path of the view that was highlighted.
    public let indexPath: IndexPath

    /// The component owned by the view that was highlighted.
    public let anyComponent: AnyComponent

    /// The content owned by the view that was highlighted.
    public let content: UIView?
  }

  /// A closure that's called when the cell was highlighted
  let handler: (EventContext) -> Void
}
#endif
