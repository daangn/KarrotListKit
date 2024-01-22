//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Combine
import Foundation

public protocol ComponentPrefetchable {}

public protocol RemoteImagePrefetchable: ComponentPrefetchable {
  var remoteImageURLs: [URL] { get }
}

public protocol CollectionViewPrefetchingPlugin {
  func prefetch(dataSource: ComponentPrefetchable) -> AnyCancellable?
}
