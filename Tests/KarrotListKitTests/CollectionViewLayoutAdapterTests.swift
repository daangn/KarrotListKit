//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Combine
import UIKit

import XCTest

@testable import KarrotListKit

final class CollectionViewLayoutAdapterTests: XCTestCase {

  final class NSCollectionLayoutEnvironmentDummy: NSObject, NSCollectionLayoutEnvironment {
    var container: NSCollectionLayoutContainer { fatalError() }
    var traitCollection: UITraitCollection { .init() }
  }

  final class ComponentSizeStorageDummy: ComponentSizeStorage {

    func cellSize(for hash: AnyHashable) -> SizeContext? {
      nil
    }

    func headerSize(for hash: AnyHashable) -> SizeContext? {
      nil
    }

    func footerSize(for hash: AnyHashable) -> SizeContext? {
      nil
    }

    func setCellSize(_ size: SizeContext, for hash: AnyHashable) {}

    func setHeaderSize(_ size: SizeContext, for hash: AnyHashable) {}

    func setFooterSize(_ size: SizeContext, for hash: AnyHashable) {}
  }

  final class CollectionViewLayoutAdapterDataSourceStub: CollectionViewLayoutAdapterDataSource {

    var section: Section?
    func sectionItem(at index: Int) -> Section? {
      section
    }

    var sizeStorageStub: ComponentSizeStorage!
    func sizeStorage() -> ComponentSizeStorage {
      sizeStorageStub
    }
  }

  func sut() -> CollectionViewLayoutAdapter {
    CollectionViewLayoutAdapter()
  }
}

// MARK: - Initializes

extension CollectionViewLayoutAdapterTests {

  func test_given_no_setup_when_sectionLayout_then_return_nil() {
    // given
    let sut = sut()

    // when
    let sectionLayout = sut.sectionLayout(index: 0, environment: NSCollectionLayoutEnvironmentDummy())

    // then
    XCTAssertNil(sectionLayout)
  }

  func test_given_nil_section_when_sectionLayout_then_return_nil() {
    let dataSource = CollectionViewLayoutAdapterDataSourceStub()
    dataSource.section = nil

    let sut = sut()
    sut.dataSource = dataSource

    // when
    let sectionLayout = sut.sectionLayout(index: 0, environment: NSCollectionLayoutEnvironmentDummy())

    // then
    XCTAssertNil(sectionLayout)
  }

  func test_given_section_without_layout_when_sectionLayout_then_return_nil() {
    let dataSource = CollectionViewLayoutAdapterDataSourceStub()
    dataSource.section = Section(id: UUID(), cells: [])

    let sut = sut()
    sut.dataSource = dataSource

    // when
    let sectionLayout = sut.sectionLayout(index: 0, environment: NSCollectionLayoutEnvironmentDummy())

    // then
    XCTAssertNil(sectionLayout)
  }

  func test_given_section_with_emptyCell_when_sectionLayout_then_return_nil() {
    let dataSource = CollectionViewLayoutAdapterDataSourceStub()
    dataSource.section = Section(id: UUID(), cells: []).withSectionLayout { _ in
      .init(
        group: .init(
          layoutSize: .init(
            widthDimension: .absolute(44.0),
            heightDimension: .absolute(44.0)
          )
        )
      )
    }

    let sut = sut()
    sut.dataSource = dataSource

    // when
    let sectionLayout = sut.sectionLayout(index: 0, environment: NSCollectionLayoutEnvironmentDummy())

    // then
    XCTAssertNil(sectionLayout)
  }

  func test_given_valid_section_when_sectionLayout_then_return_sectionLayout() {
    let dataSource = CollectionViewLayoutAdapterDataSourceStub()
    dataSource.sizeStorageStub = ComponentSizeStorageDummy()
    dataSource.section = Section(
      id: UUID(),
      cells: [Cell(id: UUID(), component: DummyComponent())]
    ).withSectionLayout { _ in
      .init(
        group: .vertical(
          layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(0), heightDimension: .absolute(0)),
          subitems: [.init(layoutSize: .init(widthDimension: .absolute(0), heightDimension: .absolute(0)))]
        )
      )
    }

    let sut = sut()
    sut.dataSource = dataSource

    // when
    let sectionLayout = sut.sectionLayout(index: 0, environment: NSCollectionLayoutEnvironmentDummy())

    // then
    XCTAssertNotNil(sectionLayout)
  }
}
