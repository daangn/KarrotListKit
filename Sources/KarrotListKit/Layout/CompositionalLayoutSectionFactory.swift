//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

public protocol CompositionalLayoutSectionFactory {

  typealias LayoutContext = (
    section: Section,
    index: Int,
    environment: NSCollectionLayoutEnvironment,
    sizeStorage: ComponentSizeStorage
  )

  typealias SectionLayout = (_ context: LayoutContext) -> NSCollectionLayoutSection?

  func makeSectionLayout() -> SectionLayout?
}
