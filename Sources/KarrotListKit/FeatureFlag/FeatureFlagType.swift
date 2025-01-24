//
//  Copyright (c) 2025 Danggeun Market Inc.
//

import Foundation

/// Define the feature flags
public enum FeatureFlagType: Equatable {

  /// Improve scrolling performance using calculated view size.
  /// You can find more information at https://developer.apple.com/documentation/uikit/building-high-performance-lists-and-collection-views
  case usesCachedViewSize
}
