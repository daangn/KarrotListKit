//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

import KarrotFoundation

public struct AnyViewModel: Equatable {

  private let base: any Equatable

  init(_ base: some Component) {
    self.base = base.viewModel
  }

  public static func == (lhs: AnyViewModel, rhs: AnyViewModel) -> Bool {
    lhs.base.isEqual(rhs.base)
  }
}

public struct AnyComponent: Component, Equatable {
  private let box: any ComponentBox

  public var base: any Component {
    box.base
  }

  public var layoutMode: ContentLayoutMode {
    box.layoutMode
  }

  public var reuseIdentifier: String {
    box.reuseIdentifier
  }

  public var viewModel: AnyViewModel {
    AnyViewModel(box.base)
  }

  public init(_ base: some Component) {
    self.box = AnyComponentBox(base)
  }

  public func renderContent(coordinator: Any) -> UIView {
    box.renderContent(coordinator: coordinator)
  }

  public func render(in content: UIView, coordinator: Any) {
    box.render(in: content, coordinator: coordinator)
  }

  public func layout(content: UIView, in container: UIView) {
    box.layout(content: content, in: container)
  }

  public func `as`<T>(_: T.Type) -> T? {
    box.base as? T
  }

  public func makeCoordinator() -> Any {
    box.makeCoordinator()
  }

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
