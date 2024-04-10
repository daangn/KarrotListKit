//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

/// The `SupplementaryView` that represents a supplementary view in a `UICollectionView`.
///
/// The framework supports commonly used header or footer.
/// To represent the header or footer, you can add them to the `Section` using the `withHeader`, `withFooter` modifiers.
/// The code below is a sample code.
///
/// ```swift
/// Section(id: UUID()) {
///   ...
/// }
/// .withHeader(MyComponent())
/// .withFooter(MyComponent())
/// ```
public struct SupplementaryView: Equatable, ListingViewEventHandler {

  /// A type-erased component for supplementary view.
  public let component: AnyComponent

  /// The kind of the supplementary view.
  public let kind: String

  /// The alignment of the supplementary view.
  public let alignment: NSRectAlignment

  let eventStorage = ListingViewEventStorage()

  // MARK: - Initializer

  /// The initializer method that creates a SupplementaryView.
  ///
  /// - Parameters:
  ///  - kind: The kind of supplementary view to locate.
  ///  - component: A type-erased component for supplementary view.
  ///  - alignment: The alignment of the supplementary view.
  public init(kind: String, component: some Component, alignment: NSRectAlignment) {
    self.kind = kind
    self.component = AnyComponent(component)
    self.alignment = alignment
  }

  public static func == (lhs: SupplementaryView, rhs: SupplementaryView) -> Bool {
    lhs.component == rhs.component && lhs.kind == rhs.kind && lhs.alignment == rhs.alignment
  }
}

// MARK: - Event Handler

extension SupplementaryView {

  /// Register a callback handler that will be called when the component is displayed on the screen.
  ///
  /// - Parameters:
  ///  - handler: The callback handler when component is displayed on the screen.
  public func willDisplay(_ handler: @escaping (WillDisplayEvent.EventContext) -> Void) -> Self {
    registerEvent(WillDisplayEvent(handler: handler))
  }

  /// Registers a callback handler that will be called when the component is removed from the screen.
  ///
  /// - Parameters:
  ///  - handler: The callback handler when the component is removed from the screen.
  public func didEndDisplaying(_ handler: @escaping (DidEndDisplayingEvent.EventContext) -> Void) -> Self {
    registerEvent(DidEndDisplayingEvent(handler: handler))
  }
}
