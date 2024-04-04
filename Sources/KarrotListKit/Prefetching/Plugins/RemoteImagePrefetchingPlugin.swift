//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Combine
import Foundation

/// This class is a concrete implementation of the CollectionViewPrefetchingPlugin protocol.
/// It uses an instance of a type conforming to the RemoteImagePrefetching protocol to prefetch remote images.
public final class RemoteImagePrefetchingPlugin: CollectionViewPrefetchingPlugin {

  private let remoteImagePrefetcher: RemoteImagePrefetching

  /// Initializes a new instance of RemoteImagePrefetchingPlugin.
  ///
  /// - Parameter remoteImagePrefetcher: An instance of a type conforming to the RemoteImagePrefetching protocol to prefetch remote images.
  public init(remoteImagePrefetcher: RemoteImagePrefetching) {
    self.remoteImagePrefetcher = remoteImagePrefetcher
  }

  /// Prefetches resources for a given component.
  ///
  /// - Parameter component: The component that needs its resources to be prefetched.
  /// - Returns: An optional AnyCancellable instance which can be used to cancel the prefetch operation if needed.
  public func prefetch(with component: ComponentResourcePrefetchable) -> AnyCancellable? {
    guard let component = component as? ComponentRemoteImagePrefetchable else {
      return nil
    }

    let uuids = component.remoteImageURLs.compactMap {
      remoteImagePrefetcher.prefetchImage(url: $0)
    }

    return AnyCancellable { [weak self] in
      for uuid in uuids {
        self?.remoteImagePrefetcher.cancelTask(uuid: uuid)
      }
    }
  }
}
