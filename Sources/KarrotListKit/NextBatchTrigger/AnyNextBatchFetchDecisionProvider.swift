//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Foundation

/// A type-erased wrapper for any `NextBatchFetchDecisionProvider`.
public class AnyNextBatchFetchDecisionProvider: NextBatchFetchDecisionProvider {

  /// The underlying decision closure.
  private let decision: () -> Bool

  /// Initializes a new instance of `AnyNextBatchFetchDecisionProvider` with a given decision closure.
  ///
  /// - Parameter decision: A closure that returns a Boolean indicating whether the next batch fetch should start.
  public init(decision: @escaping () -> Bool) {
    self.decision = decision
  }

  /// Evaluates the decision to determine whether the next batch fetch should begin.
  ///
  /// - Returns: A Boolean value indicating whether the next batch fetch should start.
  public func shouldBeginNextBatchFetch() -> Bool {
    decision()
  }
}

/// Extension to create a type-erased `NextBatchFetchDecisionProvider`.
extension NextBatchFetchDecisionProvider where Self == AnyNextBatchFetchDecisionProvider {

  /// Creates a type-erased `NextBatchFetchDecisionProvider`.
  ///
  /// - Parameter decision: A closure that returns a Boolean indicating whether the next batch fetch should start.
  /// - Returns: An instance of `AnyNextBatchFetchDecisionProvider`.
  static func `default`(decision: @escaping () -> Bool) -> Self {
    .init(decision: decision)
  }
}
