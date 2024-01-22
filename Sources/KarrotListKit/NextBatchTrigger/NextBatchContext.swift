//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Foundation

public struct NextBatchContext {
  public enum State {
    /// 초기상태
    case pending

    /// 트리거된 상태
    case triggered
  }

  public var state: State

  public init(state: State = .pending) {
    self.state = state
  }
}
