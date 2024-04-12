//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

/// This object provides default layout factories
///
/// You can use the default layouts to implement easily and quickly different styles layout
/// If you need to create a custom layout, implement an object that conform `CompositionalLayoutSectionFactory`.
public struct DefaultCompositionalLayoutSectionFactory: CompositionalLayoutSectionFactory {

  /// The LayoutSpec enum defines the type of layouts that can be provided.
  public enum LayoutSpec {

    /// A vertical layout with specified spacing.
    case vertical(spacing: CGFloat)

    /// A horizontal layout with specified spacing and scrolling behavior.
    case horizontal(
      spacing: CGFloat,
      scrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior
    )

    /// A vertical grid layout with specified number of items in a row, item spacing, and line spacing.
    case verticalGrid(numberOfItemsInRow: Int, itemSpacing: CGFloat, lineSpacing: CGFloat)
  }

  private let spec: LayoutSpec

  /// Creates a vertical layout
  public static var vertical: Self = .init(spec: .vertical(spacing: 0))

  /// Creates a horizontal layout
  public static var horizontal: Self = .init(spec: .horizontal(spacing: 0, scrollingBehavior: .continuous))

  /// Creates a vertical layout with specified spacing.
  /// - Parameter spacing: The spacing between items in the layout. Default value is `0.0`.
  public static func vertical(spacing: CGFloat) -> Self {
    .init(spec: .vertical(spacing: spacing))
  }

  /// Creates a horizontal layout.
  /// - Parameters:
  ///   - spacing: The spacing between items in the layout. Default value is 0.0.
  ///   - scrollingBehavior: The behavior of the layout when scrolling. Default value is .continuous.
  public static func horizontal(
    spacing: CGFloat,
    scrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior = .continuous
  ) -> Self {
    .init(spec: .horizontal(spacing: spacing, scrollingBehavior: scrollingBehavior))
  }

  /// Creates a vertical grid layout.
  /// - Parameters:
  ///   - numberOfItemsInRow: The number of items in a row.
  ///   - itemSpacing: The spacing between items in the layout.
  ///   - lineSpacing: The spacing between lines in the layout.
  public static func verticalGrid(
    numberOfItemsInRow: Int,
    itemSpacing: CGFloat,
    lineSpacing: CGFloat
  ) -> Self {
    .init(
      spec: .verticalGrid(
        numberOfItemsInRow: numberOfItemsInRow,
        itemSpacing: itemSpacing,
        lineSpacing: lineSpacing
      )
    )
  }

  private var sectionContentInsets: NSDirectionalEdgeInsets?
  private var headerPinToVisibleBounds: Bool?
  private var footerPinToVisibleBounds: Bool?
  private var visibleItemsInvalidationHandler: NSCollectionLayoutSectionVisibleItemsInvalidationHandler?

  /// Creates a section layout based on the specified layout spec.
  ///
  /// - Returns: layout closure for section
  public func makeSectionLayout() -> SectionLayout? {
    switch spec {
    case .vertical(let spacing):
      return VerticalLayout(spacing: spacing)
        .insets(sectionContentInsets)
        .headerPinToVisibleBounds(headerPinToVisibleBounds)
        .footerPinToVisibleBounds(footerPinToVisibleBounds)
        .withVisibleItemsInvalidationHandler(visibleItemsInvalidationHandler)
        .makeSectionLayout()
    case .horizontal(let spacing, let scrollingBehavior):
      return HorizontalLayout(spacing: spacing, scrollingBehavior: scrollingBehavior)
        .insets(sectionContentInsets)
        .headerPinToVisibleBounds(headerPinToVisibleBounds)
        .footerPinToVisibleBounds(footerPinToVisibleBounds)
        .withVisibleItemsInvalidationHandler(visibleItemsInvalidationHandler)
        .makeSectionLayout()
    case .verticalGrid(let numberOfItemsInRow, let itemSpacing, let lineSpacing):
      return VerticalGridLayout(
        numberOfItemsInRow: numberOfItemsInRow,
        itemSpacing: itemSpacing,
        lineSpacing: lineSpacing
      )
      .insets(sectionContentInsets)
      .headerPinToVisibleBounds(headerPinToVisibleBounds)
      .footerPinToVisibleBounds(footerPinToVisibleBounds)
      .withVisibleItemsInvalidationHandler(visibleItemsInvalidationHandler)
      .makeSectionLayout()
    }
  }

  /// Sets the insets for the section.
  ///
  /// - Parameters:
  ///   - insets: insets for section
  public func withSectionContentInsets(_ insets: NSDirectionalEdgeInsets) -> Self {
    var copy = self
    copy.sectionContentInsets = insets
    return copy
  }

  /// Sets whether the header should pin to visible bounds.
  ///
  /// - Parameters:
  ///   - pinToVisibleBounds: A Boolean value that indicates whether a header is pinned to the top
  public func withHeaderPinToVisibleBounds(_ pinToVisibleBounds: Bool) -> Self {
    var copy = self
    copy.headerPinToVisibleBounds = pinToVisibleBounds
    return copy
  }

  /// Sets whether the footer should pin to visible bounds.
  ///
  /// - Parameters:
  ///   - pinToVisibleBounds: A Boolean value that indicates whether a footer is pinned to the bottom
  public func withFooterPinToVisibleBounds(_ pinToVisibleBounds: Bool) -> Self {
    var copy = self
    copy.footerPinToVisibleBounds = pinToVisibleBounds
    return copy
  }

  /// Sets the handler for invalidating visible items.
  ///
  /// - Parameters:
  ///   - handler: visible items invalidation handler
  public func withVisibleItemsInvalidationHandler(
    _ visibleItemsInvalidationHandler: NSCollectionLayoutSectionVisibleItemsInvalidationHandler?
  )
    -> Self {
    var copy = self
    copy.visibleItemsInvalidationHandler = visibleItemsInvalidationHandler
    return copy
  }
}
