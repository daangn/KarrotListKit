//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import XCTest

@testable import KarrotListKit

final class ChunkedTests: XCTestCase {

  //===----------------------------------------------------------------------===//
  // Tests for `chunks(ofCount:)`
  //===----------------------------------------------------------------------===//

  func testChunksOfCount() {
    XCTAssertEqual([Int]().chunks(ofCount: 1), [])
    XCTAssertEqual([Int]().chunks(ofCount: 5), [])

    let collection1 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    XCTAssertEqual(collection1.chunks(ofCount: 1), [[1], [2], [3], [4], [5], [6], [7], [8], [9], [10]])
    XCTAssertEqual(collection1.chunks(ofCount: 3), [[1, 2, 3], [4, 5, 6], [7, 8, 9], [10]])
    XCTAssertEqual(collection1.chunks(ofCount: 5), [[1, 2, 3, 4, 5], [6, 7, 8, 9, 10]])
    XCTAssertEqual(collection1.chunks(ofCount: 11), [[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]])

    let collection2 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
    XCTAssertEqual(collection2.chunks(ofCount: 3), [[1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11]])
  }

  func testChunksOfCountBidirectional() {
    let collection1 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

    XCTAssertEqual(collection1.chunks(ofCount: 1).reversed(), [[10], [9], [8], [7], [6], [5], [4], [3], [2], [1]])
    XCTAssertEqual(collection1.chunks(ofCount: 3).reversed(), [[10], [7, 8, 9], [4, 5, 6], [1, 2, 3]])
    XCTAssertEqual(collection1.chunks(ofCount: 5).reversed(), [[6, 7, 8, 9, 10], [1, 2, 3, 4, 5]])
    XCTAssertEqual(collection1.chunks(ofCount: 11).reversed(), [[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]])

    let collection2 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
    XCTAssertEqual(collection2.chunks(ofCount: 3).reversed(), [[10, 11], [7, 8, 9], [4, 5, 6], [1, 2, 3]])
  }

  func testChunksOfCountCount() {
    XCTAssertEqual([Int]().chunks(ofCount: 1).count, 0)
    XCTAssertEqual([Int]().chunks(ofCount: 5).count, 0)

    let collection1 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    XCTAssertEqual(collection1.chunks(ofCount: 1).count, 10)
    XCTAssertEqual(collection1.chunks(ofCount: 3).count, 4)
    XCTAssertEqual(collection1.chunks(ofCount: 5).count, 2)
    XCTAssertEqual(collection1.chunks(ofCount: 11).count, 1)

    let collection2 = (1...50).map { $0 }
    XCTAssertEqual(collection2.chunks(ofCount: 9).count, 6)
  }

  func testEmptyChunksOfCountTraversal() {
    let emptyChunks = [Int]().chunks(ofCount: 1)
    XCTAssertTrue(emptyChunks.isEmpty)
  }

  func testChunksOfCountTraversal() {
    for i in 1...10 {
      let range = 1...50
      let chunks = range.chunks(ofCount: i)
      let expectedCount = range.count / i + (range.count % i).signum()
      XCTAssertEqual(chunks.count, expectedCount)
    }
  }
}
