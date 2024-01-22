//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

public struct SupplementaryView: Equatable, ListingViewEventHandler {
  public let component: AnyComponent
  public let kind: String
  public let alignment: NSRectAlignment

  let eventStorage = ListingViewEventStorage()

  // MARK: - Initializer

  public init(kind: String, component: some Component, alignment: NSRectAlignment) {
    self.kind = kind
    self.component = AnyComponent(component)
    self.alignment = alignment
  }

  public static func == (lhs: SupplementaryView, rhs: SupplementaryView) -> Bool {
    lhs.component == rhs.component && lhs.kind == rhs.kind && lhs.alignment == rhs.alignment
  }
}

// MARK: - Event Handler

extension SupplementaryView {
  public func willDisplay(_ handler: @escaping (WillDisplayEvent.EventContext) -> Void) -> Self {
    registerEvent(WillDisplayEvent(handler: handler))
  }

  public func didEndDisplaying(_ handler: @escaping (DidEndDisplayingEvent.EventContext) -> Void) -> Self {
    registerEvent(DidEndDisplayingEvent(handler: handler))
  }
}
