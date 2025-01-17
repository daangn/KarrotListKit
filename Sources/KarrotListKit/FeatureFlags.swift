//
//  Copyright (c) 2025 Danggeun Market Inc.
//

import Foundation

/// The KarrotListKitFeatureFlags manages feature flags used in the KarrotListKit framework.
public struct KarrotListKitFeatureFlags {

  /// Representing the current FeatureFlags configuration.
  public static var current = KarrotListKitFeatureFlags(
    shouldUseCachedViewSize: { false }
  )

  /// This is a feature to improve scrolling performance.
  /// You can find more information at https://developer.apple.com/documentation/uikit/building-high-performance-lists-and-collection-views.
  public var usesCachedViewSize: Bool {
    shouldUseCachedViewSize()
  }

  private let shouldUseCachedViewSize: () -> Bool

  /// Initializes a new instance of KarrotListKitFeatureFlags.
  public init(
    shouldUseCachedViewSize: @escaping () -> Bool
  ) {
    self.shouldUseCachedViewSize = shouldUseCachedViewSize
  }
}
