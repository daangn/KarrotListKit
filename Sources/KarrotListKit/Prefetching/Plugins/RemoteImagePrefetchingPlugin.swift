//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Combine
import Foundation

public final class RemoteImagePrefetchingPlugin: CollectionViewPrefetchingPlugin {

  private let remoteImagePrefetcher: RemoteImagePrefetching

  public init(remoteImagePrefetcher: RemoteImagePrefetching) {
    self.remoteImagePrefetcher = remoteImagePrefetcher
  }

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
