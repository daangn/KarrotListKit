//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

/// This structure encapsulates the will end dragging event information and contains a closure object for handling the will end dragging event.
public struct WillEndDraggingEvent: ListingViewEvent {
  public struct EventContext {

    /// The collectionView object where the user ended the touch.
    public let collectionView: UICollectionView

    /// The velocity of the collectionView (in points per millisecond) at the moment the touch was released.
    public let velocity: CGPoint

    /// The expected offset when the scrolling action decelerates to a stop.
    public let targetContentOffset: UnsafeMutablePointer<CGPoint>
  }

  /// A closure that's called when the user finishes scrolling the content.
  let handler: (EventContext) -> Void
}
