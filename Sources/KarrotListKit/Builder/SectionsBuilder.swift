//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Foundation

/// Provides a resultBuilder for creating an array of section.
@resultBuilder
public enum SectionsBuilder {
  public static func buildBlock(_ components: Section...) -> [Section] {
    components
  }

  public static func buildBlock(_ components: [Section]...) -> [Section] {
    components.flatMap { $0 }
  }

  public static func buildBlock(_ components: [Section]) -> [Section] {
    components
  }

  public static func buildOptional(_ component: [Section]?) -> [Section] {
    component ?? []
  }

  public static func buildEither(first component: [Section]) -> [Section] {
    component
  }

  public static func buildEither(second component: [Section]) -> [Section] {
    component
  }

  public static func buildExpression(_ expression: Section...) -> [Section] {
    expression
  }

  public static func buildExpression(_ expression: [Section]...) -> [Section] {
    expression.flatMap { $0 }
  }

  public static func buildArray(_ components: [[Section]]) -> [Section] {
    components.flatMap { $0 }
  }
}
