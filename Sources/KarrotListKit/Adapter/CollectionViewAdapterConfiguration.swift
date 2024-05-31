//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

/// The configuration for the CollectionViewAdapter object.
public struct CollectionViewAdapterConfiguration {

  /// Configure the RefreshControl of the CollectionView
  ///
  /// The default value is .disabled().
  public let refreshControl: RefreshControl

  /// If the changeSet count exceeds the batchUpdateInterruptCount,
  /// the UICollectionView operates with reloadData instead of animated updates.
  ///
  /// The default value is 100.
  public let batchUpdateInterruptCount: Int

  /// The number of screens left to scroll before the next batch triggering.
  ///
  /// The default value is 2.0.
  public let leadingScreensForNextBatching: Double

  /// Initialize a new instance of `UICollectionViewAdapter`.
  ///
  /// - Parameters:
  ///   - refreshControl: RefreshControl of the CollectionView
  ///   - batchUpdateInterruptCount: maximum changeSet count that can be animated updates
  ///   - leadingScreensForNextBatching: number of screens left to scroll before the next batch triggering
  public init(
    refreshControl: RefreshControl = .disabled(),
    batchUpdateInterruptCount: Int = 100,
    leadingScreensForNextBatching: Double = 2.0
  ) {
    self.refreshControl = refreshControl
    self.batchUpdateInterruptCount = batchUpdateInterruptCount
    self.leadingScreensForNextBatching = leadingScreensForNextBatching
  }
}


// MARK: - RefreshControl

extension CollectionViewAdapterConfiguration {

  /// Represents the information of the RefreshControl.
  public struct RefreshControl {

    /// Indicates whether the RefreshControl is applied or not.
    public let isEnabled: Bool

    // The tint color of the RefreshControl.
    public let tintColor: UIColor

    /// Use this function to enable the RefreshControl and set its tint color.
    public static func enabled(tintColor: UIColor) -> RefreshControl {
      .init(isEnabled: true, tintColor: tintColor)
    }

    /// Use this function to disable the RefreshControl.
    public static func disabled() -> RefreshControl {
      .init(isEnabled: false, tintColor: .clear)
    }
  }
}
