//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Foundation

/// Provides a resultBuilder for creating an array of cell.
@resultBuilder
public enum CellsBuilder {
  public static func buildBlock(_ components: Cell...) -> [Cell] {
    components
  }

  public static func buildBlock(_ components: [Cell]...) -> [Cell] {
    components.flatMap { $0 }
  }

  public static func buildBlock(_ components: [Cell]) -> [Cell] {
    components
  }

  public static func buildOptional(_ component: [Cell]?) -> [Cell] {
    component ?? []
  }

  public static func buildEither(first component: [Cell]) -> [Cell] {
    component
  }

  public static func buildEither(first component: Cell...) -> [Cell] {
    component
  }

  public static func buildEither(first component: () -> [Cell]) -> [Cell] {
    component()
  }

  public static func buildEither(second component: [Cell]) -> [Cell] {
    component
  }

  public static func buildExpression(_ expression: Cell...) -> [Cell] {
    expression
  }

  public static func buildExpression(_ expression: [Cell]...) -> [Cell] {
    expression.flatMap { $0 }
  }

  public static func buildArray(_ components: [[Cell]]) -> [Cell] {
    components.flatMap { $0 }
  }
}
