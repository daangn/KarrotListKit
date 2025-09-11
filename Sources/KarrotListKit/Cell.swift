//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import DifferenceKit

#if canImport(UIKit)
import UIKit

/// The `Cell` that representing a UICollectionViewCell.
public struct Cell: Identifiable, ListingViewEventHandler {

  /// The identifier for `Cell`
  public let id: AnyHashable

  /// A type-erased component for cell
  public let component: AnyComponent

  let eventStorage = ListingViewEventStorage()

  // MARK: - Initializer

  /// The initializer method that creates a Cell.
  ///
  /// - Parameters:
  ///  - id: The identifier that identifies the Cell.
  ///  - component: A type-erased component for cell.
  public init(id: some Hashable, component: some Component) {
    self.id = id
    self.component = AnyComponent(component)
  }

  /// The initializer method that creates a Cell.
  ///
  /// - Parameters:
  ///  - id: The identifier that identifies the Cell.
  ///  - component: A type-erased component for cell.
  public init(component: some IdentifiableComponent) {
    self.id = component.id
    self.component = AnyComponent(component)
  }
}

// MARK: - Event Handler

extension Cell {

  /// Register a callback handler that will be called when the cell was selected
  ///
  /// - Parameters:
  ///  - handler: The callback handler for select event
  public func didSelect(_ handler: @escaping (DidSelectEvent.EventContext) -> Void) -> Self {
    registerEvent(DidSelectEvent(handler: handler))
  }

  /// Register a callback handler that will be called when the cell being added
  ///
  /// - Parameters:
  ///  - handler: The callback handler for will display event
  public func willDisplay(_ handler: @escaping (WillDisplayEvent.EventContext) -> Void) -> Self {
    registerEvent(WillDisplayEvent(handler: handler))
  }

  /// Register a callback handler that will be called when the cell was removed.
  ///
  /// - Parameters:
  ///  - handler: The callback handler for did end display event
  public func didEndDisplay(_ handler: @escaping (DidEndDisplayingEvent.EventContext) -> Void) -> Self {
    registerEvent(DidEndDisplayingEvent(handler: handler))
  }

  /// Register a callback handler that will be called when the cell was highlighted.
  ///
  /// - Parameters:
  ///  - handler: The callback handler for highlight event
  public func onHighlight(_ handler: @escaping (HighlightEvent.EventContext) -> Void) -> Self {
    registerEvent(HighlightEvent(handler: handler))
  }

  /// Register a callback handler that will be called when the cell was unhighlighted.
  ///
  /// - Parameters:
  ///  - handler: The callback handler for unhighlight event
  public func onUnhighlight(_ handler: @escaping (UnhighlightEvent.EventContext) -> Void) -> Self {
    registerEvent(UnhighlightEvent(handler: handler))
  }
}

// MARK: - Hashable

extension Cell: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  public static func == (lhs: Cell, rhs: Cell) -> Bool {
    lhs.id == rhs.id && lhs.component == rhs.component
  }
}

// MARK: - Differentiable

extension Cell: Differentiable {
  public var differenceIdentifier: AnyHashable {
    id
  }

  public func isContentEqual(to source: Self) -> Bool {
    self == source
  }
}
#endif
