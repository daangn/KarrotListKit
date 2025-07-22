//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

/// A protocol that creates and returns layout for section
///
/// Any type that conforms to this protocol is responsible for creating `NSCollectionLayoutSection`.
/// It provides a default implementation for calculating sizes for `Cell` and `ReusableViews`.
public protocol CompositionalLayoutSectionFactory {

  /// A type that represents the context for layout, including the section, index, layout environment, and size storage.
  /// `ComponentSizeStorage` caches the actual size information of the component.
  typealias LayoutContext = (
    section: Section,
    index: Int,
    environment: NSCollectionLayoutEnvironment
  )

  /// A type that represents a layout closure for section.
  typealias SectionLayout = (_ context: LayoutContext) -> NSCollectionLayoutSection?

  /// Creates a layout for a section.
  ///
  /// - Returns: layout closure for section
  func makeSectionLayout() -> SectionLayout?
}
