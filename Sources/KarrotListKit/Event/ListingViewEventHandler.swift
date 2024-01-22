//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Foundation

protocol ListingViewEventHandler {

  var eventStorage: ListingViewEventStorage { get }

  func registerEvent<E: ListingViewEvent>(_ event: E) -> Self

  func event<E: ListingViewEvent>(for type: E.Type) -> E?
}

// MARK: - Default Implementation

extension ListingViewEventHandler {
  func registerEvent(_ event: some ListingViewEvent) -> Self {
    eventStorage.register(event)
    return self
  }

  func event<E: ListingViewEvent>(for type: E.Type) -> E? {
    eventStorage.event(for: type)
  }
}
