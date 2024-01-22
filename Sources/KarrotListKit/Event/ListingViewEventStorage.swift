//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Foundation

final class ListingViewEventStorage {

  private var source: [AnyHashable: Any] = [:]

  func event<E: ListingViewEvent>(for type: E.Type) -> E? {
    source[String(reflecting: type)] as? E
  }

  func register(_ event: some ListingViewEvent) {
    source[event.id] = event
  }
}
