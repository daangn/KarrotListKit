//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

/// A type-erased wrapper for any `Component`'s `ViewModel` that conforms to `Equatable`.
public struct AnyViewModel: Equatable {

  private let base: any Equatable

  /// Creates a new instance of `AnyViewModel` by wrapping the given `Component`'s `ViewModel`.
  ///
  /// - Parameter base: The `Component` whose `ViewModel` to wrap.
  init(_ base: some Component) {
    self.base = base.viewModel
  }

  /// Returns a Boolean value indicating whether two `AnyViewModel` instances are equal.
  ///
  /// - Parameters:
  ///   - lhs: The left-hand side value to compare.
  ///   - rhs: The right-hand side value to compare.
  /// - Returns: `true` if `lhs` and `rhs` are equal; otherwise, `false`.
  public static func == (lhs: AnyViewModel, rhs: AnyViewModel) -> Bool {
    lhs.base.isEqual(rhs.base)
  }
}

/// A type-erased wrapper for any `Component` that conforms to `Component` and `Equatable`.
public struct AnyComponent: Component, Equatable {
  private let box: any ComponentBox

  /// The any `Component` instance.
  public var base: any Component {
    box.base
  }

  /// The layout mode of the component's content.
  public var layoutMode: ContentLayoutMode {
    box.layoutMode
  }

  /// A reuse identifier for the component.
  public var reuseIdentifier: String {
    box.reuseIdentifier
  }

  /// The `ViewModel` of the component.
  public var viewModel: AnyViewModel {
    AnyViewModel(box.base)
  }

  /// Creates a new instance of `AnyComponent` by wrapping the given `Component`.
  ///
  /// - Parameter base: The `Component` to wrap.
  public init(_ base: some Component) {
    self.box = AnyComponentBox(base)
  }

  /// Creates the content object and configures its initial state.
  ///
  /// - Parameter coordinator: The coordinator to use for rendering the content.
  /// - Returns: The rendered content.
  public func renderContent(coordinator: Any) -> UIView {
    box.renderContent(coordinator: coordinator)
  }

  /// Updates the state of the specified content with new information
  ///
  /// - Parameters:
  ///   - content: The content to render.
  ///   - coordinator: The coordinator to use for rendering.
  public func render(in content: UIView, coordinator: Any) {
    box.render(in: content, coordinator: coordinator)
  }

  /// Lays out the specified content in the given container view.
  ///
  /// - Parameters:
  ///   - content: The content to layout.
  ///   - container: The view to layout the content in.
  public func layout(content: UIView, in container: UIView) {
    box.layout(content: content, in: container)
  }

  /// Attempts to downcast the underlying `Component` to the specified type.
  ///
  /// - Parameter _: The type to downcast to.
  /// - Returns: The underlying `Component` as the specified type, or `nil` if the downcast fails.
  public func `as`<T>(_: T.Type) -> T? {
    box.base as? T
  }

  /// Creates the custom instance that you use to communicate changes from your view to other parts of your SwiftUI interface.
  ///
  /// If your view doesn’t interact with SwiftUI interface, providing a coordinator is unnecessary.
  /// - Returns: A new `Coordinator` instance.
  public func makeCoordinator() -> Any {
    box.makeCoordinator()
  }

  /// Returns a Boolean value indicating whether two `AnyComponent` instances are equal.
  ///
  /// - Parameters:
  ///   - lhs: The left-hand side value to compare.
  ///   - rhs: The right-hand side value to compare.
  /// - Returns: `true` if `lhs` and `rhs` are equal; otherwise, `false`.
  public static func == (lhs: AnyComponent, rhs: AnyComponent) -> Bool {
    lhs.viewModel == rhs.viewModel
  }
}

private protocol ComponentBox {
  associatedtype Base: Component

  var base: Base { get }
  var reuseIdentifier: String { get }
  var layoutMode: ContentLayoutMode { get }
  var viewModel: Base.ViewModel { get }

  func renderContent(coordinator: Any) -> UIView
  func render(in content: UIView, coordinator: Any)
  func layout(content: UIView, in container: UIView)
  func makeCoordinator() -> Any
}

private struct AnyComponentBox<Base: Component>: ComponentBox {

  var reuseIdentifier: String {
    baseComponent.reuseIdentifier
  }

  var viewModel: Base.ViewModel {
    baseComponent.viewModel
  }

  var layoutMode: ContentLayoutMode {
    baseComponent.layoutMode
  }

  var baseComponent: Base

  var base: Base {
    baseComponent
  }

  init(_ base: Base) {
    self.baseComponent = base
  }

  func renderContent(coordinator: Any) -> UIView {
    baseComponent.renderContent(coordinator: coordinator as! Base.Coordinator)
  }

  func render(in content: UIView, coordinator: Any) {
    guard let content = content as? Base.Content,
          let coordinator = coordinator as? Base.Coordinator
    else {
      return
    }

    baseComponent.render(in: content, coordinator: coordinator)
  }

  func layout(content: UIView, in container: UIView) {
    guard let content = content as? Base.Content else { return }

    baseComponent.layout(content: content, in: container)
  }

  func makeCoordinator() -> Any {
    baseComponent.makeCoordinator()
  }
}
