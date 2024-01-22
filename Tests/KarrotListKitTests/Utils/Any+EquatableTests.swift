//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import XCTest

@testable import KarrotListKit

final class Any_EquatableTests: XCTestCase {

  func test_isEqual_any_opaque_type_의_값이_같으면_true() {
    // given
    let object1: any SomeProtocol = SomeObject(id: 1)
    let object2: any SomeProtocol = SomeObject(id: 1)

    // then
    XCTAssertTrue(object1.isEqual(object2))
  }

  func test_isEqual_any_opaque_type_의_값이_다르면_false() {
    // given
    let object1: any SomeProtocol = SomeObject(id: 1)
    let object2: any SomeProtocol = SomeObject(id: 2)

    // then
    XCTAssertFalse(object1.isEqual(object2))
  }
}


// MARK: - Test Object

private protocol SomeProtocol: Equatable {
  var id: Int { get }
}

private struct SomeObject: SomeProtocol {
  let id: Int
}
