//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Foundation

public enum ContentLayoutMode: Equatable {
  /// 너비 / 높이 부모 크기에 맞추기
  case fitContainer

  /// 너비는 부모가 결정하고, 높이는 내부 Content 크기에 맞추기
  case flexibleHeight(estimatedHeight: CGFloat)

  /// 높이는 부모가 결정하고, 너비는 내부 Content 크기에 맞추기
  case flexibleWidth(estimatedWidth: CGFloat)

  /// 너비 / 높이 모두 내부 Content 크기에 맞추기
  case fitContent(estimatedSize: CGSize)
}
