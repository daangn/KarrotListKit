//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Foundation

/// Provides a `NextBatchTrigger` for pagination functionality.
///
/// This object makes it easy to implement paging functionality with simple code.
/// Below is a sample code.
///
/// ```swift
/// Section(id: UUID()) {
///  ...
/// }
/// .withNextBatchTrigger(threshold: 7) {
///  /// handle next batch trigger
/// }
/// ```
/// A trigger occurs when the threshold is greater than or equal to the index of the last content minus the index of the currently displayed content.
public final class NextBatchTrigger {

  /// The threshold that occurs trigger event
  public let threshold: Int

  /// The current state for next batch trigger
  public var context: NextBatchContext

  /// A closure that is called when a trigger occurs
  public let handler: (_ context: NextBatchContext) -> Void

  /// The initializer method that creates a NextBatchTrigger.
  ///
  /// - Parameters:
  ///  - threshold: The threshold that occurs trigger event
  ///  - context: The initial state for next batch trigger
  ///  - handler: A closure that is called when a trigger occurs
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
