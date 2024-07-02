//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Foundation

/// The `List` that representing a UICollectionView.
public struct List: ListingViewEventHandler {

  /// A array of section that representing Section UI.
  public var sections: [Section]

  let eventStorage = ListingViewEventStorage()

  // MARK: - Initializer

  /// The initializer method that creates a List.
  ///
  /// - Parameters:
  ///  - sections: An array of section to be displayed on the screen.
  public init(
    sections: [Section]
  ) {
    self.sections = sections
  }

  /// The initializer method that creates a List.
  ///
  /// - Parameters:
  ///  - sections: The Builder that creates an array of section to be displayed on the screen.
  public init(
    @SectionsBuilder _ sections: () -> [Section]
  ) {
    self.sections = sections()
  }
}

// MARK: - Event Handler

extension List {

  /// Register a callback handler that will be called when the user scrolls the content view.
  ///
  /// - Parameters:
  ///  - handler: The callback handler for did scroll event
  public func didScroll(_ handler: @escaping (DidScrollEvent.EventContext) -> Void) -> Self {
    registerEvent(DidScrollEvent(handler: handler))
  }

  /// Register a callback handler that will be called when the user pull to refresh.
  ///
  /// - Parameters:
  ///  - handler: The callback handler for did pull to refresh event
  public func onRefresh(_ handler: @escaping (PullToRefreshEvent.EventContext) -> Void) -> Self {
    registerEvent(PullToRefreshEvent(handler: handler))
  }

  /// Register a callback handler that will be called when the user scrolls near the end of the content view.
  ///
  /// - Parameters:
  ///   - offset: The offset from the end of the content view that triggers the event. Default is two times the height of the content view.
  ///   - handler: The callback handler for on reached end event.
  /// - Returns: An updated `List` with the registered event handler.
  public func onReachedEnd(
    offsetFromEnd offset: ReachedEndEvent.OffsetFromEnd = .relativeToContainerSize(multiplier: 2.0),
    _ handler: @escaping (ReachedEndEvent.EventContext) -> Void
  ) -> Self {
    registerEvent(
      ReachedEndEvent(
        offset: offset,
        handler: handler
      )
    )
  }

  /// Register a callback handler that will be called when the scrollView is about to start scrolling the content.
  ///
  /// - Parameters:
  ///  - handler: The callback handler for will begin dragging event
  public func willBeginDragging(_ handler: @escaping (WillBeginDraggingEvent.EventContext) -> Void) -> Self {
    registerEvent(WillBeginDraggingEvent(handler: handler))
  }

  /// Register a callback handler that will be called when the user finishes scrolling the content.
  ///
  /// - Parameters:
  ///  - handler: The callback handler for will end dragging event
  public func willEndDragging(_ handler: @escaping (WillEndDraggingEvent.EventContext) -> Void) -> Self {
    registerEvent(WillEndDraggingEvent(handler: handler))
  }

  /// Register a callback handler that will be called when the user finished scrolling the content.
  ///
  /// - Parameters:
  ///  - handler: The callback handler for did end dragging event
  public func didEndDragging(_ handler: @escaping (DidEndDraggingEvent.EventContext) -> Void) -> Self {
    registerEvent(DidEndDraggingEvent(handler: handler))
  }

  /// Register a callback handler that will be called when the scroll view scrolled to the top of the content.
  ///
  /// - Parameters:
  ///  - handler: The callback handler for did scroll to top event
  public func didScrollToTop(_ handler: @escaping (DidScrollToTopEvent.EventContext) -> Void) -> Self {
    registerEvent(DidScrollToTopEvent(handler: handler))
  }

  /// Register a callback handler that will be called when the scroll view is starting to decelerate the scrolling movement.
  ///
  /// - Parameters:
  ///  - handler: The callback handler for will begin decelerating event
  public func willBeginDecelerating(_ handler: @escaping (WillBeginDeceleratingEvent.EventContext) -> Void) -> Self {
    registerEvent(WillBeginDeceleratingEvent(handler: handler))
  }

  /// Register a callback handler that will be called when the scroll view ended decelerating the scrolling movement.
  ///
  /// - Parameters:
  ///  - handler: The callback handler for did end decelerating event
  public func didEndDecelerating(_ handler: @escaping (DidEndDeceleratingEvent.EventContext) -> Void) -> Self {
    registerEvent(DidEndDeceleratingEvent(handler: handler))
  }
}
