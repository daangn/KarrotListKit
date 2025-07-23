import UIKit

import KarrotListKit

/// Grid layout section factory for variable height content
///
/// - Description: Divides the container's full width equally by `numberOfItemsInRow` to set each item's width,
///   and uses injected values at initialization for item and header/footer supplementary view heights.
///   Row spacing (`interGroupSpacing`) and item spacing (`interItemSpacing`) can be specified.
public struct VerticalGridLayout {
  /// Number of items to display per row
  private let numberOfItemsInRow: Int

  /// Height of items
  private let itemHeightDimension: NSCollectionLayoutDimension

  /// Height of header view
  private let headerHeightDimension: NSCollectionLayoutDimension?

  /// Height of footer view
  private let footerHeightDimension: NSCollectionLayoutDimension?

  /// Horizontal spacing between items (columns)
  private let interItemSpacing: CGFloat

  /// Vertical spacing between groups (rows)
  private let interGroupSpacing: CGFloat

  /// Section internal margins (Directional insets)
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
  ///   - numberOfItemsInRow: Number of items per row
  ///   - itemHeightDimension: Height of items
  ///   - headerHeightDimension: Height of header view, uses `.estimated(44.0)` if not specified
  ///   - footerHeightDimension: Height of footer view, uses `.estimated(44.0)` if not specified
  ///   - interItemSpacing: Horizontal spacing between items
  ///   - interGroupSpacing: Vertical spacing between groups (rows)
  public init(
    numberOfItemsInRow: Int,
    itemHeightDimension: NSCollectionLayoutDimension,
    headerHeightDimension: NSCollectionLayoutDimension? = nil,
    footerHeightDimension: NSCollectionLayoutDimension? = nil,
    interItemSpacing: CGFloat,
    interGroupSpacing: CGFloat
  ) {
    self.numberOfItemsInRow = numberOfItemsInRow
    self.itemHeightDimension = itemHeightDimension
    self.headerHeightDimension = headerHeightDimension
    self.footerHeightDimension = footerHeightDimension
    self.interItemSpacing = interItemSpacing
    self.interGroupSpacing = interGroupSpacing
  }

  /// Creates a layout for a section.
  public func makeSectionLayout() -> CompositionalLayoutSectionProvider {
    CompositionalLayoutSectionProvider { context -> NSCollectionLayoutSection? in
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

      let group = makeLayoutGroup()
      group.interItemSpacing = .fixed(interItemSpacing)

      let section = NSCollectionLayoutSection(group: group)
      section.interGroupSpacing = interGroupSpacing

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

  private func makeLayoutGroup() -> NSCollectionLayoutGroup {
    let cellSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0 / CGFloat(numberOfItemsInRow)),
      heightDimension: itemHeightDimension
    )

    return NSCollectionLayoutGroup.horizontal(
      layoutSize: .init(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: itemHeightDimension
      ),
      repeatingSubitem: NSCollectionLayoutItem(
        layoutSize: cellSize
      ),
      count: numberOfItemsInRow
    )
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
