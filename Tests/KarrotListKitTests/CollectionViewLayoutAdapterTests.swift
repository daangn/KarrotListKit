//
//  CollectionViewLayoutAdapterTests.swift
//
//
//  Created by Jaxtyn on 2024/04/05.
//

import UIKit
import Combine

import XCTest

@testable import KarrotListKit

final class CollectionViewLayoutAdapterTests: XCTestCase {

  final class NSCollectionLayoutEnvironmentDummy: NSObject, NSCollectionLayoutEnvironment {
    var container: NSCollectionLayoutContainer { fatalError() }
    var traitCollection: UITraitCollection { .init() }
  }

  func sut() -> CollectionViewLayoutAdapter {
    CollectionViewLayoutAdapter()
  }
}

// MARK: - Initializes

extension CollectionViewLayoutAdapterTests {

  func test_given_applied_list_when_sectionLayout_then_make_with_context() {
    var layoutContext: CompositionalLayoutSectionFactory.LayoutContext!
    let environment = NSCollectionLayoutEnvironmentDummy()
    let sut = sut()
    let collectionView = UICollectionView(layoutAdapter: sut)
    let collectionViewAdapter = CollectionViewAdapter(
      configuration: .init(),
      collectionView: collectionView,
      layoutAdapter: sut
    ).then {
      // given: applied list
      $0.apply(
        List {
          Section(
            id: UUID().uuidString,
            cells: [Cell(id: UUID().uuidString, component: DummyComponent())]
          )
          .withSectionLayout { context in
            layoutContext = context
            return nil
          }
        }
      )
    }

    // when
    _ = sut.sectionLayout(index: 0, environment: environment)

    // then
    XCTAssertEqual(layoutContext.index, 0)
    XCTAssertEqual(layoutContext.section, collectionViewAdapter.snapshot()?.sections[0])
    XCTAssertIdentical(layoutContext.environment, environment)
  }
}
