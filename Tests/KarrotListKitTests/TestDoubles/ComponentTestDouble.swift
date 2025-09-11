//
//  Copyright (c) 2024 Danggeun Market Inc.
//

#if canImport(UIKit)
import UIKit

@testable import KarrotListKit

struct DummyComponent: Component, ComponentResourcePrefetchable {

  struct ViewModel: Equatable {}

  typealias Content = UIView
  typealias Coordinator = Void

  var layoutMode: ContentLayoutMode {
    .flexibleHeight(estimatedHeight: 44.0)
  }

  var viewModel: ViewModel = .init()

  func renderContent(coordinator: Coordinator) -> UIView {
    UIView()
  }

  func render(in content: UIView, coordinator: Coordinator) {
    // nothing
  }
}

struct ComponentStub: Component {

  struct ViewModel: Equatable {}

  typealias Content = UIView
  typealias Coordinator = Void

  var viewModel: ViewModel {
    viewModelStub
  }

  var layoutMode: ContentLayoutMode {
    layoutModeStub
  }

  var layoutModeStub: ContentLayoutMode!
  var viewModelStub: ViewModel!
  var contentStub: UIView!

  func renderContent(coordinator: Coordinator) -> UIView {
    contentStub
  }

  func render(in content: UIView, coordinator: Coordinator) {
    // nothing
  }
}

class ComponentSpy: Component {

  struct ViewModel: Equatable {}

  typealias Content = UIView
  typealias Coordinator = Void

  var viewModel: ViewModel {
    .init()
  }

  var layoutMode: ContentLayoutMode {
    .fitContainer
  }

  var renderContentCallCount = 0
  func renderContent(coordinator: Coordinator) -> UIView {
    renderContentCallCount += 1
    return .init()
  }

  var renderCallCount = 0
  func render(in content: UIView, coordinator: Coordinator) {
    renderCallCount += 1
  }
}
#endif
