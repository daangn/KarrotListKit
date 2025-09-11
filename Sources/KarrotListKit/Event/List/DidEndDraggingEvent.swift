//
//  Copyright (c) 2024 Danggeun Market Inc.
//

#if canImport(UIKit)
import UIKit

/// This structure encapsulates the did end dragging event information and contains a closure object for handling the did end dragging event.
public struct DidEndDraggingEvent: ListingViewEvent {
  public struct EventContext {

    /// The collectionView object where the user ended the touch.
    public let collectionView: UICollectionView

    /// true if the scrolling movement will continue, but decelerate, after a touch-up gesture during a dragging operation.\
    /// If the value is false, scrolling stops immediately upon touch-up.
    public let decelerate: Bool
  }

  /// A closure that's called when the user finished scrolling the content.
  let handler: (EventContext) -> Void
}
#endif
