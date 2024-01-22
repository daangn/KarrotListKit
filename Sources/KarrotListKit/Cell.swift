//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

import DifferenceKit

public struct Cell: Identifiable, ListingViewEventHandler {
  public let id: AnyHashable
  public let component: AnyComponent

  let eventStorage = ListingViewEventStorage()

  // MARK: - Initializer

  public init(id: some Hashable, component: some Component) {
    self.id = id
    self.component = AnyComponent(component)
  }

  public init(component: some IdentifiableComponent) {
    self.id = component.id
    self.component = AnyComponent(component)
  }
}

// MARK: - Event Handler

extension Cell {
  public func didSelect(_ handler: @escaping (DidSelectEvent.EventContext) -> Void) -> Self {
    registerEvent(DidSelectEvent(handler: handler))
  }

  public func willDisplay(_ handler: @escaping (WillDisplayEvent.EventContext) -> Void) -> Self {
    registerEvent(WillDisplayEvent(handler: handler))
  }

  public func didEndDisplay(_ handler: @escaping (DidEndDisplayEvent.EventContext) -> Void) -> Self {
    registerEvent(DidEndDisplayEvent(handler: handler))
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
