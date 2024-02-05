//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

public struct CollectionViewAdapterConfiguration {

  /// CollectionView 의 RefreshControl 구성
  ///
  /// 기본값은 `.disabled()` 입니다.
  public let refreshControl: RefreshControl

  /// changeSet 이 `batchUpdateInterruptCount` 수를 넘기면 
  /// `UICollectionView` 가 animated updates 가 아닌 reloadData 로 동작합니다.
  ///
  /// 기본값은 `100` 입니다.
  public let batchUpdateInterruptCount: Int

  public init(
    refreshControl: RefreshControl = .disabled(),
    batchUpdateInterruptCount: Int = 100
  ) {
    self.refreshControl = refreshControl
    self.batchUpdateInterruptCount = batchUpdateInterruptCount
  }
}


// MARK: - RefreshControl

extension CollectionViewAdapterConfiguration {

  public struct RefreshControl {

    /// RefreshControl 적용 여부
    public let isEnabled: Bool

    /// RefreshControl 의 tintColor
    public let tintColor: UIColor

    public static func enabled(tintColor: UIColor) -> RefreshControl {
      .init(isEnabled: true, tintColor: tintColor)
    }

    public static func disabled() -> RefreshControl {
      .init(isEnabled: false, tintColor: .clear)
    }
  }
}
