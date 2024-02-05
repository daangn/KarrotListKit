//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Foundation

public protocol RemoteImagePrefetching {
  func prefetchImage(url: URL) -> UUID?
  func cancelTask(uuid: UUID)
}
