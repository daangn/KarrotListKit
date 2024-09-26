//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Foundation

/// The approaches for updating the content of a `UICollectionView`.
public enum CollectionViewAdapterUpdateStrategy {
  
  /// Performs animated batch updates by calling `performBatchUpdates(…)` with the new content.
  case animatedBatchUpdates

  /// Performs non-animated batch updates by wrapping a call to `performBatchUpdates(…)` with the
  /// new content within a `UIView.performWithoutAnimation(…)` closure.
  ///
  /// More performant than `reloadData`, as it does not recreate and reconfigure all visible
  /// cells.
  case nonanimatedBatchUpdates

  /// Performs non-animated updates by calling `reloadData()`, which recreates and reconfigures
  /// all visible cells.
  ///
  /// UIKit engineers have suggested that we should never need to call `reloadData` on updates,
  /// and instead just use batch updates for all content updates.
  case reloadData
}
