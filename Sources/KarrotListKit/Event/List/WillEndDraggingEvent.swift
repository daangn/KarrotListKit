//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

public struct WillEndDraggingEvent: ListingViewEvent {
  public struct EventContext {
    public let collectionView: UICollectionView
    public let velocity: CGPoint
    public let targetContentOffset: UnsafeMutablePointer<CGPoint>
  }

  let handler: (EventContext) -> Void
}
