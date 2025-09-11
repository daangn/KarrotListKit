//
//  Copyright (c) 2024 Danggeun Market Inc.
//

#if canImport(UIKit)
import UIKit

/// This structure encapsulates the did scroll to top event information and contains a closure object for handling the did scroll to top event.
public struct DidScrollToTopEvent: ListingViewEvent {
  public struct EventContext {

    /// The collectionView object that perform the scrolling operation.
    public let collectionView: UICollectionView
  }

  /// A closure that's called when the user scrolled to the top of the content.
  let handler: (EventContext) -> Void
}
#endif
