//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import XCTest

@testable import KarrotListKit

final class ResultBuildersTests: XCTestCase {

  typealias CLList = List<CompositionalLayout>
  typealias CLSection = Section<CompositionalLayout.SectionLayout>

  struct DummyComponent: Component {
    struct ViewModel: Equatable {}
    typealias Content = UIView
    typealias Coordinator = Void
    var viewModel: ViewModel = .init()
    func renderContent(coordinator: Coordinator) -> UIView { fatalError() }
    func render(in content: UIView, coordinator: Coordinator) { fatalError() }
  }
}

// MARK: - CellBuilder

extension ResultBuildersTests {

  func test_build_cells() {
    let section = CLSection(id: UUID()) {
      Cell(id: UUID(), component: DummyComponent())
      Cell(id: UUID(), component: DummyComponent())
      Cell(id: UUID(), component: DummyComponent())
      Cell(id: UUID(), component: DummyComponent())
      Cell(id: UUID(), component: DummyComponent())
    }

    XCTAssertEqual(section.cells.count, 5)
  }

  func test_build_cells_with_if_condition() {
    let condition = true

    let section = CLSection(id: UUID()) {
      if condition {
        Cell(id: UUID(), component: DummyComponent())
        Cell(id: UUID(), component: DummyComponent())
        Cell(id: UUID(), component: DummyComponent())
        Cell(id: UUID(), component: DummyComponent())
        Cell(id: UUID(), component: DummyComponent())
      }
    }

    XCTAssertEqual(section.cells.count, 5)
  }

  func test_build_cells_with_else_if_condition() {
    let condition = true

    let section = CLSection(id: UUID()) {
      if !condition {
        Cell(id: UUID(), component: DummyComponent())
      } else if condition {
        Cell(id: UUID(), component: DummyComponent())
        Cell(id: UUID(), component: DummyComponent())
        Cell(id: UUID(), component: DummyComponent())
      }
    }

    XCTAssertEqual(section.cells.count, 3)
  }

  func test_build_cells_with_else_condition() {
    let condition = true

    let section = CLSection(id: UUID()) {
      if !condition {
        Cell(id: UUID(), component: DummyComponent())
      } else {
        Cell(id: UUID(), component: DummyComponent())
        Cell(id: UUID(), component: DummyComponent())
        Cell(id: UUID(), component: DummyComponent())
      }
    }

    XCTAssertEqual(section.cells.count, 3)
  }

  func test_build_cells_with_loop() {
    let section = CLSection(id: UUID()) {
      for _ in 0 ..< 5 {
        Cell(id: UUID(), component: DummyComponent())
      }
    }

    XCTAssertEqual(section.cells.count, 5)
  }

  func test_build_cells_with_map() {
    let section = CLSection(id: UUID()) {
      (0 ..< 5).map { _ in
        Cell(id: UUID(), component: DummyComponent())
      }
    }

    XCTAssertEqual(section.cells.count, 5)
  }

  func test_build_cells_with_combination() {
    let section = CLSection(id: UUID()) {
      Cell(id: UUID(), component: DummyComponent())
      if true {
        Cell(id: UUID(), component: DummyComponent())
        (0 ..< 5).map { _ in
          Cell(id: UUID(), component: DummyComponent())
        }
        Cell(id: UUID(), component: DummyComponent())
      }
      for i in 0 ..< 10 {
        if i % 2 == 0 {
          Cell(id: UUID(), component: DummyComponent())
        } else {
          Cell(id: UUID(), component: DummyComponent())
          Cell(id: UUID(), component: DummyComponent())
        }
      }
    }

    XCTAssertEqual(section.cells.count, 23)
  }
}

// MARK: - SectionBuilder

extension ResultBuildersTests {

  func test_build_sections() {
    let list = CLList {
      CLSection(id: UUID(), cells: [])
      CLSection(id: UUID(), cells: [])
      CLSection(id: UUID(), cells: [])
      CLSection(id: UUID(), cells: [])
      CLSection(id: UUID(), cells: [])
    }

    XCTAssertEqual(list.sections.count, 5)
  }

  func test_build_sections_with_if_condition() {
    let condition = true

    let list = CLList {
      if condition {
        CLSection(id: UUID(), cells: [])
        CLSection(id: UUID(), cells: [])
        CLSection(id: UUID(), cells: [])
        CLSection(id: UUID(), cells: [])
        CLSection(id: UUID(), cells: [])
      }
    }

    XCTAssertEqual(list.sections.count, 5)
  }

  func test_build_sections_with_else_if_condition() {
    let condition = true

    let list = CLList {
      if !condition {
        CLSection(id: UUID(), cells: [])
      } else if condition {
        CLSection(id: UUID(), cells: [])
        CLSection(id: UUID(), cells: [])
        CLSection(id: UUID(), cells: [])
      }
    }

    XCTAssertEqual(list.sections.count, 3)
  }

  func test_build_sections_with_else_condition() {
    let condition = true

    let list = CLList {
      if !condition {
        CLSection(id: UUID(), cells: [])
      } else {
        CLSection(id: UUID(), cells: [])
        CLSection(id: UUID(), cells: [])
        CLSection(id: UUID(), cells: [])
      }
    }

    XCTAssertEqual(list.sections.count, 3)
  }

  func test_build_sections_with_loop() {
    let list = CLList {
      for _ in 0 ..< 5 {
        CLSection(id: UUID(), cells: [])
      }
    }

    XCTAssertEqual(list.sections.count, 5)
  }

  func test_build_sections_with_map() {
    let list = CLList {
      (0 ..< 5).map { _ in
        CLSection(id: UUID(), cells: [])
      }
    }

    XCTAssertEqual(list.sections.count, 5)
  }

  func test_build_sections_with_combination() {
    let list = CLList {
      CLSection(id: UUID(), cells: [])
      if true {
        CLSection(id: UUID(), cells: [])
        (0 ..< 5).map { _ in
          CLSection(id: UUID(), cells: [])
        }
        CLSection(id: UUID(), cells: [])
      }
      for i in 0 ..< 10 {
        if i % 2 == 0 {
          CLSection(id: UUID(), cells: [])
        } else {
          CLSection(id: UUID(), cells: [])
          CLSection(id: UUID(), cells: [])
        }
      }
    }

    XCTAssertEqual(list.sections.count, 23)
  }
}
