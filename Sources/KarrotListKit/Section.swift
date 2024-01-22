//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

import DifferenceKit
import Then

public struct Section: Identifiable, ListingViewEventHandler, Then {
  public let id: AnyHashable
  public var header: SupplementaryView?
  public var cells: [Cell]
  public var footer: SupplementaryView?
  public var nextBatchTrigger: NextBatchTrigger?
  private var sectionLayout: CompositionalLayoutSectionFactory.SectionLayout?
  let eventStorage: ListingViewEventStorage

  // MARK: - Initializer

  public init(
    id: some Hashable,
    cells: [Cell]
  ) {
    self.id = id
    self.cells = cells
    self.eventStorage = ListingViewEventStorage()
  }

  public init(
    id: some Hashable,
    @CellsBuilder _ cells: () -> [Cell]
  ) {
    self.id = id
    self.cells = cells()
    self.eventStorage = ListingViewEventStorage()
  }

  public func withSectionLayout(_ sectionLayout: CompositionalLayoutSectionFactory.SectionLayout?) -> Self {
    var copy = self
    copy.sectionLayout = sectionLayout
    return copy
  }

  public func withSectionLayout(_ layoutMaker: CompositionalLayoutSectionFactory) -> Self {
    var copy = self
    copy.sectionLayout = layoutMaker.makeSectionLayout()
    return copy
  }

  public func withSectionLayout(_ defaultLayoutMaker: DefaultCompositionalLayoutSectionFactory) -> Self {
    var copy = self
    copy.sectionLayout = defaultLayoutMaker.makeSectionLayout()
    return copy
  }

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

  public func withNextBatchTrigger(_ trigger: NextBatchTrigger?) -> Self {
    var copy = self
    copy.nextBatchTrigger = trigger
    return copy
  }

  func layout(
    index: Int,
    environment: NSCollectionLayoutEnvironment,
    sizeStorage: ComponentSizeStorage
  )
    -> NSCollectionLayoutSection? {
    sectionLayout?((self, index, environment, sizeStorage))
  }
}

// MARK: - Event Handler

extension Section {
  @discardableResult
  public func willDisplayHeader(_ handler: @escaping (WillDisplayEvent.EventContext) -> Void) -> Self {
    var copy = self
    copy.header = header?.willDisplay(handler)
    return copy
  }

  @discardableResult
  public func willDisplayFooter(_ handler: @escaping (WillDisplayEvent.EventContext) -> Void) -> Self {
    var copy = self
    copy.footer = footer?.willDisplay(handler)
    return copy
  }

  public func didEndDisplayHeader(_ handler: @escaping (DidEndDisplayingEvent.EventContext) -> Void) -> Self {
    var copy = self
    copy.header = header?.didEndDisplaying(handler)
    return copy
  }

  public func didEndDisplayFooter(_ handler: @escaping (DidEndDisplayingEvent.EventContext) -> Void) -> Self {
    var copy = self
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

  public init(source: Section, elements cells: some Collection<Cell>) {
    self = source
    self.cells = Array(cells)
  }

  public func isContentEqual(to source: Self) -> Bool {
    self == source
  }
}
