//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

/// A protocol that creates and returns layout for section
///
/// Any type that conforms to this protocol is responsible for creating `NSCollectionLayoutSection`.
/// It provides a default implementation for calculating sizes for `Cell` and `ReusableViews`.
public protocol CompositionalLayoutSectionFactory {

  /// A type that represents the context for layout, including the section, index, layout environment, and size storage.
  /// `ComponentSizeStorage` caches the actual size information of the component.
  typealias LayoutContext = (
    section: Section,
    index: Int,
    environment: NSCollectionLayoutEnvironment,
    sizeStorage: ComponentSizeStorage
  )

  /// A type that represents a layout closure for section.
  typealias SectionLayout = (_ context: LayoutContext) -> NSCollectionLayoutSection?

  /// Creates a layout for a section.
  ///
  /// - Returns: layout closure for section
  func makeSectionLayout() -> SectionLayout?

  /// Make layout items for cells.
  ///
  /// - Parameters:
  ///   - cells: cells for size calculation
  ///   - sizeStorage: The storage that cached size of the cell component.
  /// - Returns: layout items for cells
  func layoutCellItems(cells: [Cell], sizeStorage: ComponentSizeStorage) -> [NSCollectionLayoutItem]

  /// Make layout item for a section header.
  ///
  /// - Parameters:
  ///   - section: The section that contains header
  ///   - sizeStorage: The storage that cached size of the header component.
  /// - Returns: layout item for header
  func layoutHeaderItem(section: Section, sizeStorage: ComponentSizeStorage)
    -> NSCollectionLayoutBoundarySupplementaryItem?

  /// Make layout item for a section footer.
  ///
  /// - Parameters:
  ///   - section: The section that contains footer
  ///   - sizeStorage: The storage that cached size of the footer component.
  /// - Returns: layout item for footer
  func layoutFooterItem(section: Section, sizeStorage: ComponentSizeStorage)
    -> NSCollectionLayoutBoundarySupplementaryItem?
}

extension CompositionalLayoutSectionFactory {

  /// Default Implementation factory method for cells
  ///
  /// - Parameters:
  ///   - cells: cells for size calculation
  ///   - sizeStorage: The storage that cached size of the cell component.
  /// - Returns: layout items for cells
  public func layoutCellItems(cells: [Cell], sizeStorage: ComponentSizeStorage) -> [NSCollectionLayoutItem] {
    cells.map {
      if let sizeContext = sizeStorage.cellSize(for: $0.id),
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

  /// Default Implementation factory method for header
  ///
  /// - Parameters:
  ///   - section: The section that contains header
  ///   - sizeStorage: The storage that cached size of the header component.
  /// - Returns: layout item for header
  public func layoutHeaderItem(
    section: Section,
    sizeStorage: ComponentSizeStorage
  ) -> NSCollectionLayoutBoundarySupplementaryItem? {
    guard let header = section.header else {
      return nil
    }

    if let sizeContext = sizeStorage.headerSize(for: section.id),
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

  /// Default Implementation factory method for footer
  ///
  /// - Parameters:
  ///   - section: The section that contains footer
  ///   - sizeStorage: The storage that cached size of the footer component.
  /// - Returns: layout item for footer
  public func layoutFooterItem(
    section: Section,
    sizeStorage: ComponentSizeStorage
  ) -> NSCollectionLayoutBoundarySupplementaryItem? {
    guard let footer = section.footer else {
      return nil
    }

    if let sizeContext = sizeStorage.footerSize(for: section.id),
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
