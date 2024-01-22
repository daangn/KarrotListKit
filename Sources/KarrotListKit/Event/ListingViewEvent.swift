//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Foundation

protocol ListingViewEvent {
  associatedtype Input
  associatedtype Output

  var id: AnyHashable { get }

  var handler: (Input) -> Output { get }
}

// MARK: - Default Implementation

extension ListingViewEvent {
  var id: AnyHashable {
    String(reflecting: Self.self)
  }
}
