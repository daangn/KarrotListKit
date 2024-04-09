//
//  ComponentTests.swift
//
//
//  Created by Jaxtyn on 2024/04/02.
//

import XCTest

@testable import KarrotListKit

final class ComponentTests: XCTestCase {

  struct FatalComponent: Component {
    struct ViewModel: Equatable { }
    typealias Content = UIView
    typealias Coordinator = Void
    var layoutMode: ContentLayoutMode { fatalError() }
    var viewModel: ViewModel = .init()
    func renderContent(coordinator: Coordinator) -> UIView { fatalError() }
    func render(in content: UIView, coordinator: Coordinator) { fatalError() }
  }

  func test_given_same_type_when_compare_reuseIdentifier_then_equal() {
    // given
    let component1 = DummyComponent()
    let component2 = DummyComponent()

    // when & then
    XCTAssertEqual(component1.reuseIdentifier, component2.reuseIdentifier)
  }

  func test_given_other_type_when_compare_reuseIdentifier_then_not_equal() {
    // given
    let component1 = DummyComponent()
    let component2 = FatalComponent()

    // when & then
    XCTAssertNotEqual(component1.reuseIdentifier, component2.reuseIdentifier)
  }

  func test_when_layout_then_fit_container() {
    // given
    let component = DummyComponent()
    let content = component.renderContent(coordinator: ())
    let frame = CGRect(x: 0, y: 0, width: 200.0, height: 200.0)
    let container = UIView(frame: frame)

    // when
    component.layout(content: content, in: container)
    container.layoutIfNeeded()

    // then
    XCTAssertEqual(content.frame, frame)
  }
}
