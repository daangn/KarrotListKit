//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

public protocol CompositionalLayoutSectionFactory {

  typealias LayoutContext = (
    section: Section,
    index: Int,
    environment: NSCollectionLayoutEnvironment,
    sizeStorage: ComponentSizeStorage
  )

  typealias SectionLayout = (_ context: LayoutContext) -> NSCollectionLayoutSection?

  func makeSectionLayout() -> SectionLayout?

  func layoutCellItems(cells: [Cell], sizeStorage: ComponentSizeStorage) -> [NSCollectionLayoutItem]

  func layoutHeaderItem(section: Section, sizeStorage: ComponentSizeStorage) -> NSCollectionLayoutBoundarySupplementaryItem?

  func layoutFooterItem(section: Section, sizeStorage: ComponentSizeStorage) -> NSCollectionLayoutBoundarySupplementaryItem?
}

extension CompositionalLayoutSectionFactory {
  public func layoutCellItems(cells: [Cell], sizeStorage: ComponentSizeStorage) -> [NSCollectionLayoutItem] {
    cells.map {
      if let sizeContext = sizeStorage.cellSizeStore[$0.id],
         sizeContext.viewModel == $0.component.viewModel {
        return NSCollectionLayoutItem(layoutSize: makeLayoutSize(
          mode: $0.component.layoutMode,
          size: sizeContext.size
        ))
      } else {
        return NSCollectionLayoutItem(
          layoutSize: makeLayoutSize(mode: $0.component.layoutMode)
        )
      }
    }
  }

  public func layoutHeaderItem(
    section: Section,
    sizeStorage: ComponentSizeStorage
  ) -> NSCollectionLayoutBoundarySupplementaryItem? {
    guard let header = section.header else {
      return nil
    }

    if let sizeContext = sizeStorage.headerSizeStore[section.id],
       sizeContext.viewModel == header.component.viewModel {
      return NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: makeLayoutSize(
          mode: header.component.layoutMode,
          size: sizeContext.size
        ),
        elementKind: header.kind,
        alignment: header.alignment
      )
    } else {
      return NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: makeLayoutSize(mode: header.component.layoutMode),
        elementKind: header.kind,
        alignment: header.alignment
      )
    }
  }

  public func layoutFooterItem(
    section: Section,
    sizeStorage: ComponentSizeStorage
  ) -> NSCollectionLayoutBoundarySupplementaryItem? {
    guard let footer = section.footer else {
      return nil
    }

    if let sizeContext = sizeStorage.footerSizeStore[section.id],
       sizeContext.viewModel == footer.component.viewModel {
      return NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: makeLayoutSize(
          mode: footer.component.layoutMode,
          size: sizeContext.size
        ),
        elementKind: footer.kind,
        alignment: footer.alignment
      )
    } else {
      return NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: makeLayoutSize(mode: footer.component.layoutMode),
        elementKind: footer.kind,
        alignment: footer.alignment
      )
    }
  }

  private func makeLayoutSize(mode: ContentLayoutMode) -> NSCollectionLayoutSize {
    switch mode {
    case .fitContainer:
      return .init(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .fractionalHeight(1.0)
      )
    case .flexibleWidth(let estimatedWidth):
      return .init(
        widthDimension: .estimated(estimatedWidth),
        heightDimension: .fractionalHeight(1.0)
      )
    case .flexibleHeight(let estimatedHeight):
      return .init(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(estimatedHeight)
      )
    case .fitContent(let estimatedSize):
      return .init(
        widthDimension: .estimated(estimatedSize.width),
        heightDimension: .estimated(estimatedSize.height)
      )
    }
  }

  private func makeLayoutSize(mode: ContentLayoutMode, size: CGSize) -> NSCollectionLayoutSize {
    switch mode {
    case .fitContainer:
      return .init(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .fractionalHeight(1.0)
      )
    case .flexibleWidth:
      return .init(
        widthDimension: .estimated(size.width),
        heightDimension: .fractionalHeight(1.0)
      )
    case .flexibleHeight:
      return .init(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(size.height)
      )
    case .fitContent:
      return .init(
        widthDimension: .estimated(size.width),
        heightDimension: .estimated(size.height)
      )
    }
  }
}
