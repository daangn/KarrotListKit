//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Foundation

/// A protocol that prefetching remote images.
public protocol RemoteImagePrefetching {

  /// Prefetches an image from a given URL.
  ///
  /// - Parameter url: The URL of the image to be prefetched.
  /// - Returns: A UUID representing the prefetch task. This can be used to cancel the task if needed.
  func prefetchImage(url: URL) -> UUID?

  /// Cancels a prefetch task with a given UUID.
  ///
  /// - Parameter uuid: The UUID of the prefetch task to be cancelled.
  func cancelTask(uuid: UUID)
}
