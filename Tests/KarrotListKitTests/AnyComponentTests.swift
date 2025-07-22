//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import XCTest

@testable import KarrotListKit

final class AnyComponentTests: XCTestCase {

  func test_properties() {
    // given
    let component = DummyComponent()
    let anyComponent = AnyComponent(component)

    // when & then
    XCTAssertEqual(component.reuseIdentifier, anyComponent.reuseIdentifier)
  }

  func test_renderContent() {
    // given
    let content = UIView()
    var component = ComponentStub()
    component.contentStub = content
    let anyComponent = AnyComponent(component)

    // when
    let renderContent = anyComponent.renderContent(coordinator: ())

    // then
    XCTAssertIdentical(renderContent, content)
  }

  func test_render() {
    // given
    let component = ComponentSpy()
    let anyComponent = AnyComponent(component)

    // when
    anyComponent.render(in: .init(), coordinator: ())

    // then
    XCTAssertEqual(component.renderCallCount, 1)
  }

  func test_type() {
    // given
    let component = ComponentSpy()
    let anyComponent = AnyComponent(component)

    // when & then
    XCTAssertIdentical(anyComponent.as(ComponentSpy.self), component)
  }
}
