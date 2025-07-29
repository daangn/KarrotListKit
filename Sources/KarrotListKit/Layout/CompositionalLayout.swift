//
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import UIKit

/// A layout implementation that uses `UICollectionViewCompositionalLayout`.
public struct CompositionalLayout: ListLayout {
  public typealias SectionLayout = CompositionalLayoutSectionProvider

  public static func makeCollectionViewLayout(
    sections: [Section<CompositionalLayoutSectionProvider>]
  ) -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { index, environment in
      guard
        let section = sections[safe: index],
        let layout = section.layout
      else {
        fatalError("Section layout is not provided for index \(index)")
      }
      return layout.resolve(
        section: section,
        index: index,
        layoutEnvironment: environment
      )
    }
  }
}


/// A provider that creates `NSCollectionLayoutSection` instances for compositional layouts.
public struct CompositionalLayoutSectionProvider {

  /// Context information provided to the layout closure.
  public typealias LayoutContext = (
    section: Section<CompositionalLayout.SectionLayout>,
    index: Int,
    layoutEnvironment: NSCollectionLayoutEnvironment
  )

  /// A closure type that creates an `NSCollectionLayoutSection` from the provided context.
  public typealias SectionLayout = (_ context: LayoutContext) -> NSCollectionLayoutSection?

  private let sectionLayout: SectionLayout

  /// Creates a new layout provider with the given section layout closure.
  ///
  /// - Parameter sectionLayout: A closure that creates an `NSCollectionLayoutSection`.
  public init(_ sectionLayout: @escaping SectionLayout) {
    self.sectionLayout = sectionLayout
  }

  /// Creates a layout section for the given context.
  func resolve(
    section: Section<CompositionalLayout.SectionLayout>,
    index: Int,
    layoutEnvironment: NSCollectionLayoutEnvironment
  ) -> NSCollectionLayoutSection? {
    sectionLayout((
      section: section,
      index: index,
      layoutEnvironment: layoutEnvironment
    ))
  }
}
