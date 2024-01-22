//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

extension UICollectionView {
  public convenience init(layoutAdapter: CollectionViewLayoutAdaptable) {
    self.init(
      frame: .zero,
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: layoutAdapter.sectionLayout
      )
    )
  }
}
