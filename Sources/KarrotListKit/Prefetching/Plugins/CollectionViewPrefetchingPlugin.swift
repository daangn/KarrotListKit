//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Combine
import Foundation

/// A protocol that asynchronously prefetching component resource on CollectionView
public protocol CollectionViewPrefetchingPlugin {

  /// Performs the task of prefetching resources that the component needs.
  /// Returns a type of AnyCancellable? for the possibility of cancelling the prefetch operation.
  ///
  /// - Parameter component: The component that needs its resources to be prefetched.
  /// - Returns: An optional instance which can be used to cancel the prefetch operation if needed.
  func prefetch(with component: ComponentResourcePrefetchable) -> AnyCancellable?
}
