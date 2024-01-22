//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

public struct DidScrollEvent: ListingViewEvent {
  public struct EventContext {
    public let collectionView: UICollectionView
  }

  let handler: (EventContext) -> Void
}
