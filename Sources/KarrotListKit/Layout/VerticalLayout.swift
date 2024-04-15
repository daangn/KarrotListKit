//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

/// This layout supports vertical scrolling.
///
/// If the width of the Cell is the same as the width of the CollectionView and the height is fit to the size of the content, this layout can be used to vertical scrolling style UI.
/// - Note: when using a vertical layout, the layout mode of the component must be Flexible High.
public struct VerticalLayout: CompositionalLayoutSectionFactory {

  private let spacing: CGFloat
  private var sectionInsets: NSDirectionalEdgeInsets?
  private var headerPinToVisibleBounds: Bool?
  private var footerPinToVisibleBounds: Bool?
  private var visibleItemsInvalidationHandler: NSCollectionLayoutSectionVisibleItemsInvalidationHandler?

  /// Initializes a new vertical layout.
  /// - Parameter spacing: The spacing between items in the layout. Default value is `0.0`.
  public init(spacing: CGFloat = 0.0) {
    self.spacing = spacing
  }

  /// Creates a layout for a section.
  public func makeSectionLayout() -> SectionLayout? {
    { context -> NSCollectionLayoutSection? in
      let group = NSCollectionLayoutGroup.vertical(
        layoutSize: .init(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .estimated(context.environment.container.contentSize.height)
        ),
        subitems: layoutCellItems(cells: context.section.cells, sizeStorage: context.sizeStorage)
      )
      group.interItemSpacing = .fixed(spacing)

      let section = NSCollectionLayoutSection(group: group)
      if let sectionInsets {
        section.contentInsets = sectionInsets
      }

      if let visibleItemsInvalidationHandler {
        section.visibleItemsInvalidationHandler = visibleItemsInvalidationHandler
      }

      let headerItem = layoutHeaderItem(section: context.section, sizeStorage: context.sizeStorage)
      if let headerPinToVisibleBounds {
        headerItem?.pinToVisibleBounds = headerPinToVisibleBounds
      }

      let footerItem = layoutFooterItem(section: context.section, sizeStorage: context.sizeStorage)
      if let footerPinToVisibleBounds {
        footerItem?.pinToVisibleBounds = footerPinToVisibleBounds
      }

      section.boundarySupplementaryItems = [
        headerItem,
        footerItem,
      ].compactMap { $0 }

      return section
    }
  }

  /// Sets the insets for the section.
  ///
  /// - Parameters:
  ///   - insets: insets for section
  public func insets(_ insets: NSDirectionalEdgeInsets?) -> Self {
    var copy = self
    copy.sectionInsets = insets
    return copy
  }

  /// Sets whether the header should pin to visible bounds.
  ///
  /// - Parameters:
  ///   - pinToVisibleBounds: A Boolean value that indicates whether a header is pinned to the top
  public func headerPinToVisibleBounds(_ pinToVisibleBounds: Bool?) -> Self {
    var copy = self
    copy.headerPinToVisibleBounds = pinToVisibleBounds
    return copy
  }

  /// Sets whether the footer should pin to visible bounds.
  ///
  /// - Parameters:
  ///   - pinToVisibleBounds: A Boolean value that indicates whether a footer is pinned to the bottom
  public func footerPinToVisibleBounds(_ pinToVisibleBounds: Bool?) -> Self {
    var copy = self
    copy.footerPinToVisibleBounds = pinToVisibleBounds
    return copy
  }

  /// Sets the handler for invalidating visible items.
  ///
  /// - Parameters:
  ///   - handler: visible items invalidation handler
  public func withVisibleItemsInvalidationHandler(
    _ handler: NSCollectionLayoutSectionVisibleItemsInvalidationHandler?
  ) -> Self {
    var copy = self
    copy.visibleItemsInvalidationHandler = handler
    return copy
  }
}
