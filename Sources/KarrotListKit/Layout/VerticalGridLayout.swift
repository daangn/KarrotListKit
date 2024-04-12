//
//  VerticalGridLayout.swift
//  
//
//  Created by Jaxtyn on 2024/04/04.
//

import UIKit

/// This layout supports grid-style vertical scrolling.
///
/// If the number of Cells to be displayed in a row is specified, This layout makes it easy to implement.
/// - Note: when using a vertical grid layout, the layout mode of the component must be Flexible High.
public struct VerticalGridLayout: CompositionalLayoutSectionFactory {

  private let numberOfItemsInRow: Int
  private let itemSpacing: CGFloat
  private let lineSpacing: CGFloat
  private var sectionInsets: NSDirectionalEdgeInsets?
  private var headerPinToVisibleBounds: Bool?
  private var footerPinToVisibleBounds: Bool?
  private var visibleItemsInvalidationHandler: NSCollectionLayoutSectionVisibleItemsInvalidationHandler?

   /// Initializes a new vertical grid layout.
   /// - Parameters:
   ///   - numberOfItemsInRow: The number of items in a row.
   ///   - itemSpacing: The spacing between items in the layout.
   ///   - lineSpacing: The spacing between lines in the layout.
  public init(
    numberOfItemsInRow: Int,
    itemSpacing: CGFloat,
    lineSpacing: CGFloat
  ) {
    self.numberOfItemsInRow = numberOfItemsInRow
    self.itemSpacing = itemSpacing
    self.lineSpacing = lineSpacing
  }

  /// Creates a layout for a section.
  public func makeSectionLayout() -> SectionLayout? {
    { context -> NSCollectionLayoutSection? in
      var verticalGroupHeight: CGFloat = 0
      let horizontalGroups = context.section.cells.chunks(ofCount: numberOfItemsInRow).map { chunkedCells in
        let horizontalGroupHeight = layoutCellItems(cells: Array(chunkedCells), sizeStorage: context.sizeStorage)
          .max { layout1, layout2 in
            layout1.layoutSize.heightDimension.dimension < layout2.layoutSize.heightDimension.dimension
          }?.layoutSize.heightDimension ?? .estimated(context.environment.container.contentSize.height)

        verticalGroupHeight += horizontalGroupHeight.dimension

        return NSCollectionLayoutGroup.horizontal(
          layoutSize: .init(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: horizontalGroupHeight
          ),
          subitem: NSCollectionLayoutItem(
            layoutSize: .init(
              widthDimension: .fractionalWidth(1.0 / CGFloat(numberOfItemsInRow)),
              heightDimension: horizontalGroupHeight
            )
          ),
          count: numberOfItemsInRow
        ).then {
          $0.interItemSpacing = .fixed(itemSpacing)
        }
      }

      let group = NSCollectionLayoutGroup.vertical(
        layoutSize: .init(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .estimated(verticalGroupHeight)
        ),
        subitems: horizontalGroups
      ).then {
        $0.interItemSpacing = .fixed(lineSpacing)
      }

      return NSCollectionLayoutSection(group: group).then {
        if let sectionInsets = sectionInsets {
          $0.contentInsets = sectionInsets
        }

        if let visibleItemsInvalidationHandler {
          $0.visibleItemsInvalidationHandler = visibleItemsInvalidationHandler
        }

        $0.boundarySupplementaryItems = [
          layoutHeaderItem(section: context.section, sizeStorage: context.sizeStorage)?.then {
            if let headerPinToVisibleBounds {
              $0.pinToVisibleBounds = headerPinToVisibleBounds
            }
          },
          layoutFooterItem(section: context.section, sizeStorage: context.sizeStorage)?.then {
            if let footerPinToVisibleBounds {
              $0.pinToVisibleBounds = footerPinToVisibleBounds
            }
          }
        ].compactMap { $0 }
      }
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
