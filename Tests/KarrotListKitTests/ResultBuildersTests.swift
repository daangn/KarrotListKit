//
//  ResultBuildersTests.swift
//
//
//  Created by Jaxtyn on 2024/04/09.
//

import XCTest

@testable import KarrotListKit

final class ResultBuildersTests: XCTestCase {

  struct DummyComponent: Component {
    struct ViewModel: Equatable { }
    typealias Content = UIView
    typealias Coordinator = Void
    var layoutMode: ContentLayoutMode { fatalError() }
    var viewModel: ViewModel = .init()
    func renderContent(coordinator: Coordinator) -> UIView { fatalError() }
    func render(in content: UIView, coordinator: Coordinator) { fatalError() }
  }
}

// MARK: - CellBuilder

extension ResultBuildersTests {

  func test_build_cells() {
    let section = Section(id: UUID()) {
      Cell(id: UUID(), component: DummyComponent())
      Cell(id: UUID(), component: DummyComponent())
      Cell(id: UUID(), component: DummyComponent())
      Cell(id: UUID(), component: DummyComponent())
      Cell(id: UUID(), component: DummyComponent())
    }

    XCTAssertEqual(section.cells.count, 5)
  }

  func test_build_cells_with_if_condition() {
    let section = Section(id: UUID()) {
      if true {
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
    let section = Section(id: UUID()) {
      if false {
        Cell(id: UUID(), component: DummyComponent())
      } else if true {
        Cell(id: UUID(), component: DummyComponent())
        Cell(id: UUID(), component: DummyComponent())
        Cell(id: UUID(), component: DummyComponent())
      }
    }

    XCTAssertEqual(section.cells.count, 3)
  }

  func test_build_cells_with_else_condition() {
    let section = Section(id: UUID()) {
      if false {
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
    let section = Section(id: UUID()) {
      for _ in 0 ..< 5 {
        Cell(id: UUID(), component: DummyComponent())
      }
    }

    XCTAssertEqual(section.cells.count, 5)
  }

  func test_build_cells_with_map() {
    let section = Section(id: UUID()) {
      (0 ..< 5).map { _ in
        Cell(id: UUID(), component: DummyComponent())
      }
    }

    XCTAssertEqual(section.cells.count, 5)
  }

  func test_build_cells_with_combination() {
    let section = Section(id: UUID()) {
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
    let list = List {
      Section(id: UUID(), cells: [])
      Section(id: UUID(), cells: [])
      Section(id: UUID(), cells: [])
      Section(id: UUID(), cells: [])
      Section(id: UUID(), cells: [])
    }

    XCTAssertEqual(list.sections.count, 5)
  }

  func test_build_sections_with_if_condition() {
    let list = List {
      if true {
        Section(id: UUID(), cells: [])
        Section(id: UUID(), cells: [])
        Section(id: UUID(), cells: [])
        Section(id: UUID(), cells: [])
        Section(id: UUID(), cells: [])
      }
    }

    XCTAssertEqual(list.sections.count, 5)
  }

  func test_build_sections_with_else_if_condition() {
    let list = List {
      if false {
        Section(id: UUID(), cells: [])
      } else if true {
        Section(id: UUID(), cells: [])
        Section(id: UUID(), cells: [])
        Section(id: UUID(), cells: [])
      }
    }

    XCTAssertEqual(list.sections.count, 3)
  }

  func test_build_sections_with_else_condition() {
    let list = List {
      if false {
        Section(id: UUID(), cells: [])
      } else {
        Section(id: UUID(), cells: [])
        Section(id: UUID(), cells: [])
        Section(id: UUID(), cells: [])
      }
    }

    XCTAssertEqual(list.sections.count, 3)
  }

  func test_build_sections_with_loop() {
    let list = List {
      for _ in 0 ..< 5 {
        Section(id: UUID(), cells: [])
      }
    }

    XCTAssertEqual(list.sections.count, 5)
  }

  func test_build_sections_with_map() {
    let list = List {
      (0 ..< 5).map { _ in
        Section(id: UUID(), cells: [])
      }
    }

    XCTAssertEqual(list.sections.count, 5)
  }

  func test_build_sections_with_combination() {
    let list = List {
      Section(id: UUID(), cells: [])
      if true {
        Section(id: UUID(), cells: [])
        (0 ..< 5).map { _ in
          Section(id: UUID(), cells: [])
        }
        Section(id: UUID(), cells: [])
      }
      for i in 0 ..< 10 {
        if i % 2 == 0 {
          Section(id: UUID(), cells: [])
        } else {
          Section(id: UUID(), cells: [])
          Section(id: UUID(), cells: [])
        }
      }
    }

    XCTAssertEqual(list.sections.count, 23)
  }
}
