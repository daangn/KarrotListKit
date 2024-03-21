//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

/// This structure encapsulates the did scroll event information and contains a closure object for handling the did scroll event.
public struct DidScrollEvent: ListingViewEvent {
  public struct EventContext {

    /// The collectionView object in which the scrolling occurred.
    public let collectionView: UICollectionView
  }

  /// A closure that's called when the user scrolls the content view within the collectionView.
  let handler: (EventContext) -> Void
}
