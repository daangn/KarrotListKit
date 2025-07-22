import UIKit

import KarrotListKit

/// Horizontal layout section factory for variable size content
///
/// - Description: Uses injected values at initialization for item and header/footer supplementary view heights.
///   Configures horizontal scrolling behavior.
public struct HorizontalLayout: CompositionalLayoutSectionFactory {
  /// Size of individual items
  private let itemSize: NSCollectionLayoutSize

  /// Size of header items
  private let headerSize: NSCollectionLayoutSize?

  /// Size of footer items
  private let footerSize: NSCollectionLayoutSize?

  /// Horizontal spacing between items (inter-group spacing)
  private let spacing: CGFloat

  /// Horizontal scroll behavior type (continuous scroll, paging, etc.)
  private let scrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior

  /// Section internal margins (leading/trailing/top/bottom insets)
  private var sectionInsets: NSDirectionalEdgeInsets?

  /// Whether to pin header to visible bounds when scrolling
  private var headerPinToVisibleBounds: Bool?

  /// Whether to pin footer to visible bounds when scrolling
  private var footerPinToVisibleBounds: Bool?

  /// Handler called when visible items change
  private var visibleItemsInvalidationHandler: NSCollectionLayoutSectionVisibleItemsInvalidationHandler?

  /// Specifies which reference boundary to use when calculating `contentInsets` applied to headers and footers
  private var supplementaryContentInsetsReference: UIContentInsetsReference?

  /// Initializer
  ///
  /// - Parameters:
  ///   - itemSize: Size of items
  ///   - headerSize: Size of header view
  ///   - footerSize: Size of footer view
  ///   - spacing: Spacing between items (default: 0)
  ///   - scrollingBehavior: Section horizontal scroll behavior (default: .continuous)
  public init(
    itemSize: NSCollectionLayoutSize,
    headerSize: NSCollectionLayoutSize? = nil,
    footerSize: NSCollectionLayoutSize? = nil,
    spacing: CGFloat = 0.0,
    scrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior = .continuous
  ) {
    self.itemSize = itemSize
    self.headerSize = headerSize
    self.footerSize = footerSize
    self.spacing = spacing
    self.scrollingBehavior = scrollingBehavior
  }

  public func makeSectionLayout() -> SectionLayout? {
    { context -> NSCollectionLayoutSection? in
      let headerItem = context.section.header.flatMap { header in
        let item = NSCollectionLayoutBoundarySupplementaryItem(
          layoutSize: headerSize ?? NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44.0)
          ),
          elementKind: header.kind,
          alignment: header.alignment
        )
        if let headerPinToVisibleBounds {
          item.pinToVisibleBounds = headerPinToVisibleBounds
        }
        return item
      }

      let footerItem = context.section.footer.flatMap { footer in
        NSCollectionLayoutBoundarySupplementaryItem(
          layoutSize: footerSize ?? NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44.0)
          ),
          elementKind: footer.kind,
          alignment: footer.alignment
        )
      }

      if let footerPinToVisibleBounds {
        footerItem?.pinToVisibleBounds = footerPinToVisibleBounds
      }

      let group = NSCollectionLayoutGroup.horizontal(
        layoutSize: itemSize,
        subitems: [NSCollectionLayoutItem(layoutSize: itemSize)]
      )

      let section = NSCollectionLayoutSection(group: group)
      section.orthogonalScrollingBehavior = scrollingBehavior
      section.interGroupSpacing = spacing

      if let supplementaryContentInsetsReference {
        section.supplementaryContentInsetsReference = supplementaryContentInsetsReference
      }

      if let sectionInsets {
        section.contentInsets = sectionInsets
      }

      if let visibleItemsInvalidationHandler {
        section.visibleItemsInvalidationHandler = visibleItemsInvalidationHandler
      }

      section.boundarySupplementaryItems = [
        headerItem,
        footerItem,
      ].compactMap { $0 }

      return section
    }
  }

  public func insets(_ insets: NSDirectionalEdgeInsets?) -> Self {
    var copy = self
    copy.sectionInsets = insets
    return copy
  }

  public func headerPinToVisibleBounds(_ pinToVisibleBounds: Bool?) -> Self {
    var copy = self
    copy.headerPinToVisibleBounds = pinToVisibleBounds
    return copy
  }

  public func footerPinToVisibleBounds(_ pinToVisibleBounds: Bool?) -> Self {
    var copy = self
    copy.footerPinToVisibleBounds = pinToVisibleBounds
    return copy
  }

  public func withVisibleItemsInvalidationHandler(
    _ handler: NSCollectionLayoutSectionVisibleItemsInvalidationHandler?
  ) -> Self {
    var copy = self
    copy.visibleItemsInvalidationHandler = handler
    return copy
  }

  public func supplementaryContentInsetsReference(
    _ reference: UIContentInsetsReference
  ) -> Self {
    var copy = self
    copy.supplementaryContentInsetsReference = reference
    return copy
  }
}
