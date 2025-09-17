//
//  Copyright (c) 2025 Danggeun Market Inc.
//

import Foundation

/// An interface for injecting a feature flag provider.
@MainActor
public enum KarrotListKitFeatureFlag {

  /// The feature flag provider used by `KarrotListKit`.
  ///
  /// By default, this is set to `DefaultFeatureFlagProvider`.
  /// You can replace it with a custom provider to change the feature flag behavior.
  public static var provider: FeatureFlagProviding = DefaultFeatureFlagProvider()
}
