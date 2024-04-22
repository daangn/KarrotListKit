//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

/// This structure encapsulates the will begin decelerating event information and contains a closure object for handling the will begin decelerating event.
public struct WillBeginDeceleratingEvent: ListingViewEvent {
  public struct EventContext {

    /// The collectionView object that’s decelerating the scrolling of the content view.
    public let collectionView: UICollectionView
  }

  /// A closure that's called when the collection view is starting to decelerate the scrolling movement.
  let handler: (EventContext) -> Void
}
