//
//  Copyright (c) 2024 Danggeun Market Inc.
//

#if canImport(UIKit)
import UIKit

/// This structure encapsulates the did end decelerating event information and contains a closure object for handling the did end decelerating event.
public struct DidEndDeceleratingEvent: ListingViewEvent {
  public struct EventContext {

    /// The collectionView object that’s decelerating the scrolling of the content view.
    public let collectionView: UICollectionView
  }

  /// A closure that's called when the collection view ended decelerating the scrolling movement.
  let handler: (EventContext) -> Void
}
#endif
