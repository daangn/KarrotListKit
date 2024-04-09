//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

/// The Component is the smallest unit within the framework.
/// It allows for the declarative representation of data and actions to be displayed on the screen.
/// The component has an interface very similar to UIViewRepresentable. This similarity allows us to reduce the cost of migrating to SwiftUI in the future.
public protocol Component {

  /// The type of the `ViewModel` associated with the component.
  /// The ViewModel must conform to `Equatable`.
  associatedtype ViewModel: Equatable

  /// The type of the `Content` that the component represents.
  associatedtype Content: UIView

  /// The type of the `Coordinator` associated with the component.
  /// By default, this is `Void`.
  associatedtype Coordinator = Void

  /// The ViewModel of the component.
  var viewModel: ViewModel { get }

  /// A reuse identifier for the component.
  var reuseIdentifier: String { get }

  /// The layout mode of the component's content.
  var layoutMode: ContentLayoutMode { get }

  /// Creates the content object and configures its initial state.
  ///
  /// - Parameter coordinator: The coordinator to use for rendering the content.
  /// - Returns: The rendered content.
  func renderContent(coordinator: Coordinator) -> Content

  /// Updates the state of the specified content with new information
  ///
  /// - Parameters:
  ///   - content: The content to render.
  ///   - coordinator: The coordinator to use for rendering.
  func render(in content: Content, coordinator: Coordinator)

  /// Lays out the specified content in the given container view.
  ///
  /// - Parameters:
  ///   - content: The content to layout.
  ///   - container: The view to layout the content in.
  func layout(content: Content, in container: UIView)

  /// Creates the custom instance that you use to communicate changes from your view to other parts of your SwiftUI interface.
  ///
  /// If your view doesn’t interact with SwiftUI interface, providing a coordinator is unnecessary.
  /// - Returns: A new `Coordinator` instance.
  func makeCoordinator() -> Coordinator
}

extension Component {
  public var reuseIdentifier: String {
    String(reflecting: Self.self)
  }
}

extension Component where Coordinator == Void {
  public func makeCoordinator() -> Coordinator {
    ()
  }
}

extension Component where Content: UIView {
  public func layout(content: Content, in container: UIView) {
    content.translatesAutoresizingMaskIntoConstraints = false
    container.addSubview(content)
    NSLayoutConstraint.activate([
      content.topAnchor.constraint(equalTo: container.topAnchor),
      content.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      content.bottomAnchor.constraint(equalTo: container.bottomAnchor),
      content.trailingAnchor.constraint(equalTo: container.trailingAnchor),
    ])
  }
}
