//
//  Copyright (c) 2025 Danggeun Market Inc.
//

import Foundation
import XCTest

@testable import KarrotListKit

final class FeatureFlagProviderTests: XCTestCase {

  final class FeatureFlagProviderStub: FeatureFlagProviding {

    var featureFlagsStub: [FeatureFlagItem] = []

    func featureFlags() -> [FeatureFlagItem] {
      featureFlagsStub
    }
  }

  func test_default_featureFlags_is_empty() {
    // given
    let sut = KarrotListKitFeatureFlag.provider

    // when
    let featureFlags = sut.featureFlags()

    // then
    XCTAssertTrue(featureFlags.isEmpty)
  }

  func test_usesCachedViewSize_isEnabled() {
    [true, false].forEach { flag in
      // given
      let provider = FeatureFlagProviderStub()
      provider.featureFlagsStub = [.init(type: .usesCachedViewSize, isEnabled: flag)]
      KarrotListKitFeatureFlag.provider = provider

      // when
      let isEnabled = KarrotListKitFeatureFlag.provider.isEnabled(for: .usesCachedViewSize)

      // then
      XCTAssertEqual(isEnabled, flag)
    }
  }
}
