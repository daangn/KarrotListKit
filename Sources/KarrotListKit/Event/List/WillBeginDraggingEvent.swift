//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

/// This structure encapsulates the will begin dragging event information and contains a closure object for handling the will begin dragging event.
public struct WillBeginDraggingEvent: ListingViewEvent {
  public struct EventContext {

    /// The collectionView object that’s about to scroll the content view.
    public let collectionView: UICollectionView
  }

  /// A closure that's called when the collectionView is about to start scrolling the content.
  let handler: (EventContext) -> Void
}
