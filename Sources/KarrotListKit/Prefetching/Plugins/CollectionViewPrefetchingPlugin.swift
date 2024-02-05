//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Combine
import Foundation

public protocol CollectionViewPrefetchingPlugin {
  func prefetch(with component: ComponentResourcePrefetchable) -> AnyCancellable?
}
