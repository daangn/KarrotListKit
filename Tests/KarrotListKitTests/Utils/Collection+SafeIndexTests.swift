//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import XCTest

@testable import KarrotListKit

final class Collection_SafeIndexTests: XCTestCase {

  func test_safeIndex_해당_인덱스에_값이_없으면_nil_을_반환합니다() {
    // given
    let array = [1, 2, 3]

    // then
    XCTAssertNil(array[safe: 3])
  }

  func test_safeIndex_해당_인덱스에_값이_있으면_반환합니다() {
    // given
    let array = [1, 2, 3]

    // then
    XCTAssertEqual(array[safe: 1], 2)
  }
}
