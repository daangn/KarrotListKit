//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

import DifferenceKit

/// The `Section` that representing a UICollectionView Section.
///
/// The Section has a data structure similar to a Section UI hierarchy for example, an array of Cells, header, footer, etc.
/// So we just make the section data for represent Section UI
///
/// - Note: The layout depends on NSCollectionLayoutSection and
/// you must set the layout through the withSectionLayout modifier.
public struct Section<Layout>: Identifiable, ListingViewEventHandler {

  /// The identifier for `Section`
  public let id: AnyHashable

  /// The header that representing header view
  public var header: SupplementaryView?

  /// A array of cell that representing UICollectionViewCell.
  public var cells: [Cell]

  /// The footer that representing footer view
  public var footer: SupplementaryView?

  /// The layout provider for this section
  public var layout: Layout?

  let eventStorage: ListingViewEventStorage

  // MARK: - Initializer

  /// The initializer method that creates a Section.
  ///
  /// - Parameters:
  ///  - id: The identifier that identifies the Section.
  ///  - cells: An array of cell to be displayed on the screen.
  public init(
    id: some Hashable,
    cells: [Cell]
  ) {
    self.id = id
    self.cells = cells
    self.eventStorage = ListingViewEventStorage()
  }

  /// The initializer method that creates a Section.
  ///
  /// - Parameters:
  ///  - id: The identifier that identifies the Section.
  ///  - cells: The Builder that creates an array of cell to be displayed on the screen.
  public init(
    id: some Hashable,
    @CellsBuilder _ cells: () -> [Cell]
  ) {
    self.id = id
    self.cells = cells()
    self.eventStorage = ListingViewEventStorage()
  }

  /// The modifier that sets the Header for the Section.
  ///
  /// - Parameters:
  ///  - headerComponent: The component that the header represents.
  ///  - alignment: The alignment of the component.
  public func withHeader(
    _ headerComponent: some Component,
    alignment: NSRectAlignment = .top
  ) -> Self {
    var copy = self
    copy.header = .init(
      kind: UICollectionView.elementKindSectionHeader,
      component: headerComponent,
      alignment: alignment
    )
    return copy
  }

  /// The modifier that sets the Footer for the Section.
  ///
  /// - Parameters:
  ///  - footerComponent: The component that the footer represents.
  ///  - alignment: The alignment of the component.
  public func withFooter(
    _ footerComponent: some Component,
    alignment: NSRectAlignment = .bottom
  ) -> Self {
    var copy = self
    copy.footer = .init(
      kind: UICollectionView.elementKindSectionFooter,
      component: footerComponent,
      alignment: alignment
    )
    return copy
  }
}

extension Section where Layout == CompositionalLayoutSectionProvider {

  public func withSectionLayout(_ layout: CompositionalLayoutSectionProvider) -> Self {
    var copy = self
    copy.layout = layout
    return copy
  }
}

// MARK: - Event Handler

extension Section {
  /// Register a callback handler that will be called when the header is displayed on the screen.
  ///
  /// - Parameters:
  ///   - handler: The callback handler when header is displayed on the screen.
  @discardableResult
  public func willDisplayHeader(_ handler: @escaping (WillDisplayEvent.EventContext) -> Void) -> Self {
    var copy = self
    if header == nil {
      assertionFailure("Please declare the header first using [withHeader]")
    }
    copy.header = header?.willDisplay(handler)
    return copy
  }

  /// Register a callback handler that will be called when the footer is displayed on the screen.
  ///
  /// - Parameters:
  ///   - handler: The callback handler when footer is displayed on the screen.
  @discardableResult
  public func willDisplayFooter(_ handler: @escaping (WillDisplayEvent.EventContext) -> Void) -> Self {
    var copy = self
    if footer == nil {
      assertionFailure("Please declare the footer first using [withFooter]")
    }
    copy.footer = footer?.willDisplay(handler)
    return copy
  }

  /// Registers a callback handler that will be called when the header is removed from the screen.
  ///
  /// - Parameters:
  ///  - handler: The callback handler when the header is removed from the screen.
  public func didEndDisplayHeader(_ handler: @escaping (DidEndDisplayingEvent.EventContext) -> Void) -> Self {
    var copy = self
    if header == nil {
      assertionFailure("Please declare the header first using [withHeader]")
    }
    copy.header = header?.didEndDisplaying(handler)
    return copy
  }

  /// Registers a callback handler that will be called when the footer is removed from the screen.
  ///
  /// - Parameters:
  ///  - handler: The callback handler when the footer is removed from the screen.
  public func didEndDisplayFooter(_ handler: @escaping (DidEndDisplayingEvent.EventContext) -> Void) -> Self {
    var copy = self
    if footer == nil {
      assertionFailure("Please declare the footer first using [withFooter]")
    }
    copy.footer = footer?.didEndDisplaying(handler)
    return copy
  }
}

// MARK: - Hashable

extension Section: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  public static func == (lhs: Section, rhs: Section) -> Bool {
    lhs.id == rhs.id && lhs.header == rhs.header && lhs.footer == rhs.footer
  }
}

// MARK: - DifferentiableSection

extension Section: DifferentiableSection {
  public var differenceIdentifier: AnyHashable {
    id
  }

  public var elements: [Cell] {
    cells
  }

  public init(source: Section, elements cells: some Swift.Collection<Cell>) {
    self = source
    self.cells = Array(cells)
  }

  public func isContentEqual(to source: Self) -> Bool {
    self == source
  }
}
