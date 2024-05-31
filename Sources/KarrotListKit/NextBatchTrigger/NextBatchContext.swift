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

  /// A lock to ensure thread safety when updating the state.
  private let lock = NSLock()

  /// Begins the batch fetching process by setting the state to `fetching`.
  func beginBatchFetching() {
    lock.lock(); defer { self.lock.unlock() }
    state = .fetching
  }

  /// Completes the batch fetching process by setting the state to `completed`.
  public func completeBatchFetching() {
    lock.lock(); defer { self.lock.unlock() }
    state = .completed
  }
}
