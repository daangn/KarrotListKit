import UIKit

import KarrotListKit

public extension CompositionalLayoutSectionFactory where Self == HorizontalLayout {
  static func horizontalLayout(
    estimatedItemSize: CGSize,
    estimatedHeaderSize: CGSize? = nil,
    estimatedFooterSize: CGSize? = nil,
    spacing: CGFloat = 0.0,
    scrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior = .continuous
  ) -> HorizontalLayout {
    HorizontalLayout(
      itemSize: .init(
        widthDimension: .estimated(estimatedItemSize.width),
        heightDimension: .estimated(estimatedItemSize.height)
      ),
      headerSize: estimatedHeaderSize.flatMap { .init(
        widthDimension: .estimated($0.width),
        heightDimension: .estimated($0.height)
      ) },
      footerSize: estimatedFooterSize.flatMap { .init(
        widthDimension: .estimated($0.width),
        heightDimension: .estimated($0.height)
      ) },
      spacing: spacing,
      scrollingBehavior: scrollingBehavior
    )
  }

  static func horizontalLayout(
    itemSize: NSCollectionLayoutSize,
    headerSize: NSCollectionLayoutSize? = nil,
    footerSize: NSCollectionLayoutSize? = nil,
    spacing: CGFloat = 0.0,
    scrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior = .continuous
  ) -> HorizontalLayout {
    HorizontalLayout(
      itemSize: itemSize,
      headerSize: headerSize,
      footerSize: footerSize,
      spacing: spacing,
      scrollingBehavior: scrollingBehavior
    )
  }
}

public extension CompositionalLayoutSectionFactory where Self == VerticalGridLayout {
  static func verticalGridLayout(
    numberOfItemsInRow: Int,
    estimatedItemHeight: CGFloat,
    estimatedHeaderHeight: CGFloat? = nil,
    estimatedFooterHeight: CGFloat? = nil,
    interItemSpacing: CGFloat,
    interGroupSpacing: CGFloat
  ) -> VerticalGridLayout {
    VerticalGridLayout(
      numberOfItemsInRow: numberOfItemsInRow,
      itemHeightDimension: .estimated(estimatedItemHeight),
      headerHeightDimension: estimatedHeaderHeight.flatMap(
        NSCollectionLayoutDimension.estimated
      ),
      footerHeightDimension: estimatedFooterHeight.flatMap(
        NSCollectionLayoutDimension.estimated
      ),
      interItemSpacing: interItemSpacing,
      interGroupSpacing: interGroupSpacing
    )
  }

  static func verticalGridLayout(
    numberOfItemsInRow: Int,
    itemHeightDimension: NSCollectionLayoutDimension,
    headerHeightDimension: NSCollectionLayoutDimension? = nil,
    footerHeightDimension: NSCollectionLayoutDimension? = nil,
    interItemSpacing: CGFloat,
    interGroupSpacing: CGFloat
  ) -> VerticalGridLayout {
    VerticalGridLayout(
      numberOfItemsInRow: numberOfItemsInRow,
      itemHeightDimension: itemHeightDimension,
      headerHeightDimension: headerHeightDimension,
      footerHeightDimension: footerHeightDimension,
      interItemSpacing: interItemSpacing,
      interGroupSpacing: interGroupSpacing
    )
  }
}

public extension CompositionalLayoutSectionFactory where Self == VerticalLayout {
  static func verticalLayout(
    estimatedItemHeight: CGFloat,
    estimatedHeaderHeight: CGFloat? = nil,
    estimatedFooterHeight: CGFloat? = nil,
    spacing: CGFloat = 0.0
  ) -> VerticalLayout {
    VerticalLayout(
      itemHeightDimension: .estimated(estimatedItemHeight),
      headerHeightDimension: estimatedHeaderHeight.flatMap(
        NSCollectionLayoutDimension.estimated
      ),
      footerHeightDimension: estimatedFooterHeight.flatMap(
        NSCollectionLayoutDimension.estimated
      ),
      spacing: spacing
    )
  }

  static func verticalLayout(
    itemHeightDimension: NSCollectionLayoutDimension,
    headerHeightDimension: NSCollectionLayoutDimension? = nil,
    footerHeightDimension: NSCollectionLayoutDimension? = nil,
    spacing: CGFloat = 0.0
  ) -> VerticalLayout {
    VerticalLayout(
      itemHeightDimension: itemHeightDimension,
      headerHeightDimension: headerHeightDimension,
      footerHeightDimension: footerHeightDimension,
      spacing: spacing
    )
  }
}
