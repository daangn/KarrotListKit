//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Foundation

/// 마지막 콘텐츠 기준으로 N번째 콘텐츠가 노출되는 경우 트리거를 받을 수 있도록 구현되어 있어요.
public final class NextBatchTrigger {

  /// threshold >= 마지막 콘텐츠의 index - 현재 노출된 콘텐츠의 index
  /// 위 조건에서 트리거가 발생해요.
  public let threshold: Int

  /// 현재 트리거 관련 상태값을 저장
  public var context: NextBatchContext

  /// 트리거된 경우 호출되는 클로저
  public let handler: (_ context: NextBatchContext) -> Void

  public init(
    threshold: Int = 7,
    context: NextBatchContext = .init(),
    handler: @escaping (_ context: NextBatchContext) -> Void
  ) {
    self.threshold = threshold
    self.context = context
    self.handler = handler
  }
}
