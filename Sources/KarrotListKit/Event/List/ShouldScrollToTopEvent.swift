//
//  Copyright (c) 2025 Danggeun Market Inc.
//

#if canImport(UIKit)
import UIKit

/// This structure encapsulates the shouldScrollToTop event information and contains a closure object for shouldScrollToTop event.
public struct ShouldScrollToTopEvent: ListingViewEvent {
  public struct EventContext {
    /// The collectionView object requesting this information.
    public let collectionView: UICollectionView
  }

  /// A closure that's called when if the scroll view should scroll to the top of the content.
  let handler: (EventContext) -> Bool
}
#endif
