//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Foundation

/// Represents context about the next batch trigger.
public struct NextBatchContext {
  public enum State {
    /// not triggered
    case pending

    /// A trigger has occurred
    case triggered
  }

  /// state for next batch trigger
  public var state: State

  /// The initializer method that creates a NextBatchContext.
  ///
  /// - Parameters:
  ///  - state: The initial state for next batch trigger
  public init(state: State = .pending) {
    self.state = state
  }
}
