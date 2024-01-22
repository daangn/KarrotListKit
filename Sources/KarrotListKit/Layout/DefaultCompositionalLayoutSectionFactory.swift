//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

public struct DefaultCompositionalLayoutSectionFactory: CompositionalLayoutSectionFactory {

  public enum LayoutSpec {
    case vertical(spacing: CGFloat)
    case horizontal(
      spacing: CGFloat,
      scrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior
    )
    case verticalGrid(numberOfItemsInRow: Int, itemSpacing: CGFloat, lineSpacing: CGFloat)
  }

  private let spec: LayoutSpec

  public static var vertical: Self = .init(spec: .vertical(spacing: 0))

  public static var horizontal: Self = .init(spec: .horizontal(spacing: 0, scrollingBehavior: .continuous))

  public static func vertical(spacing: CGFloat) -> Self {
    .init(spec: .vertical(spacing: spacing))
  }

  public static func horizontal(
    spacing: CGFloat,
    scrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior = .continuous
  ) -> Self {
    .init(spec: .horizontal(spacing: spacing, scrollingBehavior: scrollingBehavior))
  }

  public static func verticalGrid(
    numberOfItemsInRow: Int,
    itemSpacing: CGFloat,
    lineSpacing: CGFloat
  ) -> Self {
    .init(spec: .verticalGrid(
      numberOfItemsInRow: numberOfItemsInRow,
      itemSpacing: itemSpacing,
      lineSpacing: lineSpacing
    ))
  }

  var sectionContentInsets: NSDirectionalEdgeInsets?
  var groupContentInsets: NSDirectionalEdgeInsets?
  var headerPinToVisibleBounds: Bool?
  var visibleItemsInvalidationHandler: NSCollectionLayoutSectionVisibleItemsInvalidationHandler?

  public func makeSectionLayout() -> SectionLayout? {
    switch spec {
    case .vertical(let spacing):
      return makeVerticalSectionLayout(
        spacing: spacing
      )
    case .horizontal(let spacing, let scrollingBehavior):
      return makeHorizontalSectionLayout(
        spacing: spacing,
        orthogonalScrollingBehavior: scrollingBehavior
      )
    case .verticalGrid(let numberOfItemsInRow, let itemSpacing, let lineSpacing):
      return makeVerticalGridSectionLayout(
        numberOfItemsInRow: numberOfItemsInRow,
        itemSpacing: itemSpacing,
        lineSpacing: lineSpacing
      )
    }
  }

  private func makeVerticalSectionLayout(spacing: CGFloat) -> SectionLayout? {
    { context -> NSCollectionLayoutSection? in
      let group = NSCollectionLayoutGroup.vertical(
        layoutSize: .init(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .estimated(context.environment.container.contentSize.height)
        ),
        subitems: layoutCellItems(cells: context.section.cells, sizeStorage: context.sizeStorage)
      ).then {
        $0.interItemSpacing = .fixed(spacing)
        if let contentInsets = groupContentInsets {
          $0.contentInsets = contentInsets
        }
      }

      return NSCollectionLayoutSection(group: group).then {
        if let contentInsets = sectionContentInsets {
          $0.contentInsets = contentInsets
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
          layoutFooterItem(section: context.section, sizeStorage: context.sizeStorage),
        ].compactMap { $0 }
      }
    }
  }

  private func makeHorizontalSectionLayout(
    spacing: CGFloat,
    orthogonalScrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior
  ) -> SectionLayout? {
    { context -> NSCollectionLayoutSection? in
      let group = NSCollectionLayoutGroup.horizontal(
        layoutSize: .init(
          widthDimension: .estimated(context.environment.container.contentSize.width),
          heightDimension: .estimated(context.environment.container.contentSize.height)
        ),
        subitems: layoutCellItems(cells: context.section.cells, sizeStorage: context.sizeStorage)
      ).then {
        $0.interItemSpacing = .fixed(spacing)
        if let contentInsets = groupContentInsets {
          $0.contentInsets = contentInsets
        }
      }

      return NSCollectionLayoutSection(group: group).then {
        if let contentInsets = sectionContentInsets {
          $0.contentInsets = contentInsets
        }

        if let visibleItemsInvalidationHandler {
          $0.visibleItemsInvalidationHandler = visibleItemsInvalidationHandler
        }

        $0.orthogonalScrollingBehavior = orthogonalScrollingBehavior

        $0.boundarySupplementaryItems = [
          layoutHeaderItem(section: context.section, sizeStorage: context.sizeStorage)?.then {
            if let headerPinToVisibleBounds {
              $0.pinToVisibleBounds = headerPinToVisibleBounds
            }
          },
          layoutFooterItem(section: context.section, sizeStorage: context.sizeStorage),
        ].compactMap { $0 }
      }
    }
  }

  private func makeVerticalGridSectionLayout(
    numberOfItemsInRow: Int,
    itemSpacing: CGFloat,
    lineSpacing: CGFloat
  ) -> SectionLayout? {
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
        if let contentInsets = groupContentInsets {
          $0.contentInsets = contentInsets
        }
      }

      return NSCollectionLayoutSection(group: group).then {
        if let contentInsets = sectionContentInsets {
          $0.contentInsets = contentInsets
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
          layoutFooterItem(section: context.section, sizeStorage: context.sizeStorage),
        ].compactMap { $0 }
      }
    }
  }

  public func withSectionContentInsets(_ insets: NSDirectionalEdgeInsets) -> Self {
    var copy = self
    copy.sectionContentInsets = insets
    return copy
  }

  public func withGroupContentInsets(_ insets: NSDirectionalEdgeInsets) -> Self {
    var copy = self
    copy.groupContentInsets = insets
    return copy
  }

  public func withHeaderPinToVisibleBounds(_ pinToVisibleBounds: Bool) -> Self {
    var copy = self
    copy.headerPinToVisibleBounds = pinToVisibleBounds
    return copy
  }

  public func withVisibleItemsInvalidationHandler(
    _ visibleItemsInvalidationHandler: NSCollectionLayoutSectionVisibleItemsInvalidationHandler?
  )
    -> Self {
    var copy = self
    copy.visibleItemsInvalidationHandler = visibleItemsInvalidationHandler
    return copy
  }
}
