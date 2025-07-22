//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

@testable import KarrotListKit

struct DummyComponent: Component, ComponentResourcePrefetchable {

  struct ViewModel: Equatable {}

  typealias Content = UIView
  typealias Coordinator = Void

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
