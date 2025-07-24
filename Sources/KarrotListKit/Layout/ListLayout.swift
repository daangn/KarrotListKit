//
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import UIKit

public protocol ListLayout {
  /// The type of section layout provider used by this list layout.
  associatedtype SectionProvider
  associatedtype Layout: UICollectionViewLayout

  func makeLayout(provider: SectionProvider) -> Layout
}

public struct CompositionalLayout: ListLayout {

  public typealias SectionProvider = UICollectionViewCompositionalLayoutSectionProvider
  public typealias Layout = UICollectionViewCompositionalLayout

  public func makeLayout(provider: @escaping SectionProvider) -> Layout {
    UICollectionViewCompositionalLayout(
      sectionProvider: provider
    )
  }
}
