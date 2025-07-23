import UIKit

import KarrotListKit

/// Vertical layout section factory for variable height content
///
/// - Description: Uses the container's full width to set item width,
///   and uses injected values at initialization for item and header/footer supplementary view heights.
///   Vertical spacing between groups (`spacing`) can be specified.
public struct VerticalLayout {
  /// Height of items
  private let itemHeightDimension: NSCollectionLayoutDimension

  /// Height of header view
  private let headerHeightDimension: NSCollectionLayoutDimension?

  /// Height of footer view
  private let footerHeightDimension: NSCollectionLayoutDimension?

  /// Vertical spacing between groups (items)
  private let spacing: CGFloat

  /// Section internal margins (insets)
  private var sectionInsets: NSDirectionalEdgeInsets?

  /// Whether to pin header to top of screen
  private var headerPinToVisibleBounds: Bool?

  /// Whether to pin footer to top of screen
  private var footerPinToVisibleBounds: Bool?

  /// Handler called when visible items change
  private var visibleItemsInvalidationHandler: NSCollectionLayoutSectionVisibleItemsInvalidationHandler?

  /// Specifies which reference boundary to use when calculating `contentInsets` applied to headers and footers
  private var supplementaryContentInsetsReference: UIContentInsetsReference?

  /// Initializer
  ///
  /// - Parameters:
  ///   - itemHeightDimension: Size of items
  ///   - headerHeightDimension: Height of header view, uses `.estimated(44.0)` if not specified
  ///   - footerHeightDimension: Height of footer view, uses `.estimated(44.0)` if not specified
  ///   - spacing: Vertical spacing between groups (default: 0)
  public init(
    itemHeightDimension: NSCollectionLayoutDimension,
    headerHeightDimension: NSCollectionLayoutDimension? = nil,
    footerHeightDimension: NSCollectionLayoutDimension? = nil,
    spacing: CGFloat = 0.0
  ) {
    self.itemHeightDimension = itemHeightDimension
    self.headerHeightDimension = headerHeightDimension
    self.footerHeightDimension = footerHeightDimension
    self.spacing = spacing
  }

  public func makeSectionLayout() -> CompositionalLayoutSectionProvider {
    CompositionalLayoutSectionProvider { context -> NSCollectionLayoutSection? in
      let cellSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: itemHeightDimension
      )

      let headerItem = context.section.header.flatMap { header in
        NSCollectionLayoutBoundarySupplementaryItem(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: headerHeightDimension ?? .estimated(44.0)
          ),
          elementKind: header.kind,
          alignment: header.alignment
        )
      }

      if let headerPinToVisibleBounds {
        headerItem?.pinToVisibleBounds = headerPinToVisibleBounds
      }

      let footerItem = context.section.footer.flatMap { footer in
        NSCollectionLayoutBoundarySupplementaryItem(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: footerHeightDimension ?? .estimated(44.0)
          ),
          elementKind: footer.kind,
          alignment: footer.alignment
        )
      }

      if let footerPinToVisibleBounds {
        footerItem?.pinToVisibleBounds = footerPinToVisibleBounds
      }

      let group = NSCollectionLayoutGroup.vertical(
        layoutSize: cellSize,
        subitems: [NSCollectionLayoutItem(layoutSize: cellSize)]
      )

      let section = NSCollectionLayoutSection(group: group)
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
