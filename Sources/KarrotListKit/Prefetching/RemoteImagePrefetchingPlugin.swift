//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Combine
import Foundation

import PINRemoteImage

public final class RemoteImagePrefetchingPlugin: CollectionViewPrefetchingPlugin {

  private let remoteImageManager: PINRemoteImageManager

  public init(remoteImageManager: PINRemoteImageManager = PINRemoteImageManager.shared()) {
    self.remoteImageManager = remoteImageManager
  }

  public func prefetch(dataSource: ComponentPrefetchable) -> AnyCancellable? {
    guard let dataSource = dataSource as? RemoteImagePrefetchable else {
      return nil
    }

    let uuids = dataSource.remoteImageURLs.compactMap {
      remoteImageManager.prefetchImage(with: $0)
    }

    return AnyCancellable { [weak self] in
      for uuid in uuids {
        self?.remoteImageManager.cancelTask(with: uuid)
      }
    }
  }
}

