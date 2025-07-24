//
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import UIKit

/// A protocol that defines the layout strategy for a list.
/// Each layout implementation provides its own section layout type.
public protocol ListLayout {
  /// The type of section layout provider used by this list layout.
  associatedtype SectionLayout
}


public protocol ListLayout2 {
  /// The type of section layout provider used by this list layout.
  associatedtype SectionLayout
  associatedtype Layout: UICollectionViewLayout

  func makeLayout() -> Layout
}

public struct List2<Layout: ListLayout2> {

  public var sections: [Section<Layout.SectionLayout>]

  public init(
    sections: [Section<Layout.SectionLayout>]
  ) {
    self.sections = sections
  }

  public init(
    @SectionsBuilder<Layout.SectionLayout> _ sections: () -> [Section<Layout.SectionLayout>]
  ) {
    self.sections = sections()
  }
}

public struct CompositionalLayout2: ListLayout2 {

  public typealias SectionLayout = UICollectionViewCompositionalLayoutSectionProvider
  public typealias Layout = UICollectionViewCompositionalLayout

  public func makeLayout() -> Layout {
    UICollectionViewCompositionalLayout(
      sectionProvider: <#T##UICollectionViewCompositionalLayoutSectionProvider##UICollectionViewCompositionalLayoutSectionProvider##(Int, any NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection?#>
    )
  }
}

extension Section<CompositionalLayout2> {

  func sectionProvider() -> CompositionalLayout2.SectionLayout {

  }
}
