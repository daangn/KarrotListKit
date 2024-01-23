//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Foundation

public protocol RemoteImageProviding {
  func fetchImage(url: URL) -> UUID
  func cancelTask(uuid: UUID)
}
