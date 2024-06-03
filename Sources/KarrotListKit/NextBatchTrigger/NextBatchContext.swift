//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Foundation

/// Manages the context for fetching the next batch of data.
public class NextBatchContext {

  /// Represents the current state of the batch fetching process.
  public enum State {
    /// Indicates that the fetching process is currently ongoing.
    case fetching
    /// Indicates that the fetching process has been completed.
    case completed
  }

  /// The current state of the batch fetching process.
  private(set) var state: State = .completed

  /// Begins the batch fetching process by setting the state to `fetching`.
  func beginBatchFetching() {
    state = .fetching
  }

  /// Completes the batch fetching process by setting the state to `completed`.
  ///
  /// - Important: Call this function on **Main Thread** for avoid data race.
  public func completeBatchFetching() {
    state = .completed
  }
}
