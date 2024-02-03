//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Foundation

public struct List: ListingViewEventHandler {

  public var sections: [Section]

  let eventStorage = ListingViewEventStorage()

  // MARK: - Initializer

  public init(
    sections: [Section]
  ) {
    self.sections = sections
  }

  public init(
    @SectionsBuilder _ sections: () -> [Section]
  ) {
    self.sections = sections()
  }
}

// MARK: - Event Handler

extension List {
  public func didScroll(_ handler: @escaping (DidScrollEvent.EventContext) -> Void) -> Self {
    registerEvent(DidScrollEvent(handler: handler))
  }

  public func onRefresh(_ handler: @escaping (PullToRefreshEvent.EventContext) -> Void) -> Self {
    registerEvent(PullToRefreshEvent(handler: handler))
  }

  public func willBeginDragging(_ handler: @escaping (WillBeginDraggingEvent.EventContext) -> Void) -> Self {
    registerEvent(WillBeginDraggingEvent(handler: handler))
  }

  public func willEndDragging(_ handler: @escaping (WillEndDraggingEvent.EventContext) -> Void) -> Self {
    registerEvent(WillEndDraggingEvent(handler: handler))
  }
}
