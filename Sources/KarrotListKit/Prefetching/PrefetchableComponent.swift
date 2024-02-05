//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Foundation

public protocol ComponentResourcePrefetchable {}

public protocol ComponentRemoteImagePrefetchable: ComponentResourcePrefetchable {
  var remoteImageURLs: [URL] { get }
}
