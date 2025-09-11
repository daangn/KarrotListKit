//
//  Copyright (c) 2024 Danggeun Market Inc.
//

#if canImport(UIKit)
import UIKit

/// This layout supports horizontal scrolling.
///
/// If the width and height of the Cell are both fit to the size of the content, this layout can be used to horizontal scrolling style UI.
/// - Note: when using a horizontal layout, the layout mode of the component must be Fit Content.
public struct HorizontalLayout: CompositionalLayoutSectionFactory {

  private let spacing: CGFloat
  private let scrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior
  private var sectionInsets: NSDirectionalEdgeInsets?
  private var headerPinToVisibleBounds: Bool?
  private var footerPinToVisibleBounds: Bool?
  private var visibleItemsInvalidationHandler: NSCollectionLayoutSectionVisibleItemsInvalidationHandler?

  /// Initializes a new horizontal layout.
  /// - Parameters:
  ///   - spacing: The spacing between items in the layout. Default value is 0.0.
  ///   - scrollingBehavior: The behavior of the layout when scrolling. Default value is .continuous.
  public init(
    spacing: CGFloat = 0.0,
    scrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior = .continuous
  ) {
    self.spacing = spacing
    self.scrollingBehavior = scrollingBehavior
  }

  /// Creates a layout for a section.
  public func makeSectionLayout() -> SectionLayout? {
    { context -> NSCollectionLayoutSection? in
      let group = NSCollectionLayoutGroup.horizontal(
        layoutSize: .init(
          widthDimension: .estimated(context.environment.container.contentSize.width),
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

      section.orthogonalScrollingBehavior = scrollingBehavior

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
#endif
