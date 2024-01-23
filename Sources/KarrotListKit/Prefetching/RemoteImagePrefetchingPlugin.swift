//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Combine
import Foundation

public final class RemoteImagePrefetchingPlugin: CollectionViewPrefetchingPlugin {

  private let remoteImageProvider: RemoteImageProviding

  public init(remoteImageProvider: RemoteImageProviding) {
    self.remoteImageProvider = remoteImageProvider
  }

  public func prefetch(dataSource: ComponentPrefetchable) -> AnyCancellable? {
    guard let dataSource = dataSource as? RemoteImagePrefetchable else {
      return nil
    }

    let uuids = dataSource.remoteImageURLs.compactMap {
      remoteImageProvider.fetchImage(url: $0)
    }

    return AnyCancellable { [weak self] in
      for uuid in uuids {
        self?.remoteImageProvider.cancelTask(uuid: uuid)
      }
    }
  }
}

