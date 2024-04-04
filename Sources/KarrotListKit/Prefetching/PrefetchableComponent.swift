//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Foundation

/// A protocol that needs resources to be prefetched.
public protocol ComponentResourcePrefetchable {}

/// A protocol that needs remote image to be prefetched.
public protocol ComponentRemoteImagePrefetchable: ComponentResourcePrefetchable {

  /// The remote image URLs that need to be prefetched.
  var remoteImageURLs: [URL] { get }
}
