//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import XCTest

@testable import KarrotListKit

final class ComponentSizeStorageTests: XCTestCase {

  struct DummyComponent: Component {
    struct ViewModel: Equatable {
      let value: String

      init(value: String = "") {
        self.value = value
      }
    }

    typealias Content = UIView

    var viewModel: ViewModel

    init(viewModel: ViewModel = .init()) {
      self.viewModel = viewModel
    }

    func renderContent(coordinator: ()) -> UIView {
      return .init()
    }
    
    func render(in content: UIView, coordinator: ()) { }
  }
}

// MARK: - CellSize

extension ComponentSizeStorageTests {

  func test_cellSize_id에_매핑된_사이즈가_있으면_리턴해요() {
    // given
    let cell = Cell(id: "identifier", component: DummyComponent())
    var sut = ComponentSizeStorageImpl()

    // when
    sut.setCellSize(
      .init(
        id: cell.id,
        size: CGSize(width: 100.0, height: 100.0),
        component: cell.component
      )
    )

    // then
    XCTAssertEqual(sut.cellSize(for: cell), CGSize(width: 100.0, height: 100.0))
  }

  func test_cellSize_id에_매핑된_사이즈가_있고_viewModel값이_다르면_최빈값을_리턴해요() {
    // given
    var cell1 = Cell(id: "1", component: DummyComponent(viewModel: .init(value: "1")))
    let cell2 = Cell(id: "2", component: DummyComponent())
    let cell3 = Cell(id: "3", component: DummyComponent())
    var sut = ComponentSizeStorageImpl()

    // when
    sut.setCellSize(
      .init(
        id: cell1.id,
        size: CGSize(width: 100.0, height: 100.0),
        component: cell1.component
      )
    )
    sut.setCellSize(
      .init(
        id: cell2.id,
        size: CGSize(width: 120.0, height: 120.0),
        component: cell2.component
      )
    )
    sut.setCellSize(
      .init(
        id: cell3.id,
        size: CGSize(width: 120.0, height: 120.0),
        component: cell3.component
      )
    )
    cell1 = Cell(id: "1", component: DummyComponent(viewModel: .init(value: "2")))

    // then
    XCTAssertEqual(sut.cellSize(for: cell1), CGSize(width: 120.0, height: 120.0))
  }

  func test_cellSize_id에_매핑된_사이즈가_없고_컴포넌트의_최빈값_사이즈가_있으면_최빈값을_리턴해요() {
    // given
    let cell1 = Cell(id: "1", component: DummyComponent())
    let cell2 = Cell(id: "2", component: DummyComponent())
    let cell3 = Cell(id: "3", component: DummyComponent())
    let cell4 = Cell(id: "4", component: DummyComponent())
    var sut = ComponentSizeStorageImpl()

    // when
    sut.setCellSize(
      .init(
        id: cell1.id,
        size: CGSize(width: 100.0, height: 100.0),
        component: cell1.component
      )
    )
    sut.setCellSize(
      .init(
        id: cell2.id,
        size: CGSize(width: 120.0, height: 120.0),
        component: cell2.component
      )
    )
    sut.setCellSize(
      .init(
        id: cell3.id,
        size: CGSize(width: 120.0, height: 120.0),
        component: cell3.component
      )
    )

    // then
    XCTAssertEqual(sut.cellSize(for: cell4), CGSize(width: 120.0, height: 120.0))
  }

  func test_cellSize_id에_매핑된_사이즈가_없고_컴포넌트의_최빈값_사이즈도_없으면_nil을_리턴해요() {
    // given
    let cell = Cell(id: "identifier", component: DummyComponent())
    let sut = ComponentSizeStorageImpl()

    // then
    XCTAssertNil(sut.cellSize(for: cell))
  }
}

// MARK: - HeaderSize

extension ComponentSizeStorageTests {

  func test_headerSize_id에_매핑된_사이즈가_있으면_리턴해요() {
    // given
    let componet = DummyComponent()
    let section = Section(id: "identifier", cells: []).withHeader(componet)
    var sut = ComponentSizeStorageImpl()

    // when
    sut.setHeaderSize(
      .init(id: section.id, size: .init(width: 100.0, height: 100.0), component: componet.eraseToAnyPublisher())
    )

    // then
    XCTAssertEqual(sut.headerSize(for: section), .init(width: 100.0, height: 100.0))
  }

  func test_headerSize_id에_매핑된_사이즈가_있고_viewModel값이_다르면_최빈값을_리턴해요() {
    // given
    let componet = DummyComponent()
    var section1 = Section(id: "1", cells: []).withHeader(DummyComponent(viewModel: .init(value: "1")))
    let section2 = Section(id: "2", cells: []).withHeader(componet)
    let section3 = Section(id: "3", cells: []).withHeader(componet)
    var sut = ComponentSizeStorageImpl()

    // when
    sut.setHeaderSize(
      .init(
        id: section1.id,
        size: .init(width: 100.0, height: 100.0),
        component: componet.eraseToAnyPublisher()
      )
    )
    sut.setHeaderSize(
      .init(
        id: section2.id,
        size: .init(width: 120.0, height: 120.0),
        component: componet.eraseToAnyPublisher()
      )
    )
    sut.setHeaderSize(
      .init(
        id: section3.id,
        size: .init(width: 120.0, height: 120.0),
        component: componet.eraseToAnyPublisher()
      )
    )
    section1 = section1.withHeader(DummyComponent(viewModel: .init(value: "2")))

    // then
    XCTAssertEqual(sut.headerSize(for: section1), CGSize(width: 120.0, height: 120.0))
  }

  func test_headerSize_id에_매핑된_사이즈가_없고_컴포넌트의_최빈값_사이즈가_있으면_최빈값을_리턴해요() {
    // given
    let componet = DummyComponent()
    let section1 = Section(id: "1", cells: []).withHeader(componet)
    let section2 = Section(id: "2", cells: []).withHeader(componet)
    let section3 = Section(id: "3", cells: []).withHeader(componet)
    let section4 = Section(id: "4", cells: []).withHeader(componet)
    var sut = ComponentSizeStorageImpl()

    // when
    sut.setHeaderSize(
      .init(
        id: section1.id,
        size: .init(width: 100.0, height: 100.0),
        component: componet.eraseToAnyPublisher()
      )
    )
    sut.setHeaderSize(
      .init(
        id: section2.id,
        size: .init(width: 100.0, height: 100.0),
        component: componet.eraseToAnyPublisher()
      )
    )
    sut.setHeaderSize(
      .init(
        id: section3.id,
        size: .init(width: 120.0, height: 120.0),
        component: componet.eraseToAnyPublisher()
      )
    )

    // then
    XCTAssertEqual(sut.headerSize(for: section4), CGSize(width: 100.0, height: 100.0))
  }

  func test_headerSize_id에_매핑된_사이즈가_없고_컴포넌트의_최빈값_사이즈도_없으면_nil을_리턴해요() {
    // given
    let componet = DummyComponent()
    let section = Section(id: "identifier", cells: []).withHeader(componet)
    let sut = ComponentSizeStorageImpl()

    // then
    XCTAssertNil(sut.headerSize(for: section))
  }
}

// MARK: - FooterSize

extension ComponentSizeStorageTests {

  func test_footerSize_id에_매핑된_사이즈가_있으면_리턴해요() {
    // given
    let componet = DummyComponent()
    let section = Section(id: "identifier", cells: []).withFooter(componet)
    var sut = ComponentSizeStorageImpl()

    // when
    sut.setFooterSize(
      .init(id: section.id, size: .init(width: 100.0, height: 100.0), component: componet.eraseToAnyPublisher())
    )

    // then
    XCTAssertEqual(sut.footerSize(for: section), .init(width: 100.0, height: 100.0))
  }

  func test_footerSize_id에_매핑된_사이즈가_있고_viewModel값이_다르면_최빈값을_리턴해요() {
    // given
    let componet = DummyComponent()
    var section1 = Section(id: "1", cells: []).withFooter(DummyComponent(viewModel: .init(value: "1")))
    let section2 = Section(id: "2", cells: []).withFooter(componet)
    let section3 = Section(id: "3", cells: []).withFooter(componet)
    var sut = ComponentSizeStorageImpl()

    // when
    sut.setHeaderSize(
      .init(
        id: section1.id,
        size: .init(width: 100.0, height: 100.0),
        component: componet.eraseToAnyPublisher()
      )
    )
    sut.setHeaderSize(
      .init(
        id: section2.id,
        size: .init(width: 120.0, height: 120.0),
        component: componet.eraseToAnyPublisher()
      )
    )
    sut.setHeaderSize(
      .init(
        id: section3.id,
        size: .init(width: 120.0, height: 120.0),
        component: componet.eraseToAnyPublisher()
      )
    )
    section1 = section1.withFooter(DummyComponent(viewModel: .init(value: "2")))

    // then
    XCTAssertEqual(sut.footerSize(for: section1), CGSize(width: 120.0, height: 120.0))
  }

  func test_foterSize_id에_매핑된_사이즈가_없고_컴포넌트의_최빈값_사이즈가_있으면_최빈값을_리턴해요() {
    // given
    let componet = DummyComponent()
    let section1 = Section(id: "1", cells: []).withFooter(componet)
    let section2 = Section(id: "2", cells: []).withFooter(componet)
    let section3 = Section(id: "3", cells: []).withFooter(componet)
    let section4 = Section(id: "4", cells: []).withFooter(componet)
    var sut = ComponentSizeStorageImpl()

    // when
    sut.setFooterSize(
      .init(
        id: section1.id,
        size: .init(width: 100.0, height: 100.0),
        component: componet.eraseToAnyPublisher()
      )
    )
    sut.setFooterSize(
      .init(
        id: section2.id,
        size: .init(width: 100.0, height: 100.0),
        component: componet.eraseToAnyPublisher()
      )
    )
    sut.setFooterSize(
      .init(
        id: section3.id,
        size: .init(width: 120.0, height: 120.0),
        component: componet.eraseToAnyPublisher()
      )
    )

    // then
    XCTAssertEqual(sut.footerSize(for: section4), CGSize(width: 100.0, height: 100.0))
  }

  func test_footerSize_id에_매핑된_사이즈가_없고_컴포넌트의_최빈값_사이즈도_없으면_nil을_리턴해요() {
    // given
    let componet = DummyComponent()
    let section = Section(id: "identifier", cells: []).withFooter(componet)
    let sut = ComponentSizeStorageImpl()

    // then
    XCTAssertNil(sut.footerSize(for: section))
  }
}
