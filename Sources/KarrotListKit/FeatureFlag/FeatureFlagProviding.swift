//
//  Copyright (c) 2025 Danggeun Market Inc.
//

import Foundation

/// A protocol for providing feature flags.
public protocol FeatureFlagProviding {

  /// Returns an array of feature flags.
  ///
  /// - Returns: An array of `FeatureFlagItem`.
  func featureFlags() -> [FeatureFlagItem]
}

extension FeatureFlagProviding {

  func isEnabled(for type: FeatureFlagType) -> Bool {
    featureFlags()
      .first(where: { $0.type == type })?
      .isEnabled ?? false
  }
}
