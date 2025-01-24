//
//  Copyright (c) 2025 Danggeun Market Inc.
//

import Foundation

/// Representing a feature flag item.
public struct FeatureFlagItem {

  /// The type of the feature flag.
  public let type: FeatureFlagType

  /// A Boolean value indicating whether the feature flag is enabled.
  public let isEnabled: Bool

  /// Initializes a new `FeatureFlagItem`.
  ///
  /// - Parameters:
  ///   - type: The type of the feature flag.
  ///   - isEnabled: A Boolean value indicating whether the feature flag is enabled.
  public init(
    type: FeatureFlagType,
    isEnabled: Bool
  ) {
    self.type = type
    self.isEnabled = isEnabled
  }
}
