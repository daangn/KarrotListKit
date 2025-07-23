//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Foundation

/// Provides a resultBuilder for creating an array of section.
@resultBuilder
public enum SectionsBuilder<Layout> {
  public static func buildBlock(_ components: Section<Layout>...) -> [Section<Layout>] {
    components
  }

  public static func buildBlock(_ components: [Section<Layout>]...) -> [Section<Layout>] {
    components.flatMap { $0 }
  }

  public static func buildBlock(_ components: [Section<Layout>]) -> [Section<Layout>] {
    components
  }

  public static func buildOptional(_ component: [Section<Layout>]?) -> [Section<Layout>] {
    component ?? []
  }

  public static func buildEither(first component: [Section<Layout>]) -> [Section<Layout>] {
    component
  }

  public static func buildEither(second component: [Section<Layout>]) -> [Section<Layout>] {
    component
  }

  public static func buildExpression(_ expression: Section<Layout>...) -> [Section<Layout>] {
    expression
  }

  public static func buildExpression(_ expression: [Section<Layout>]...) -> [Section<Layout>] {
    expression.flatMap { $0 }
  }

  public static func buildArray(_ components: [[Section<Layout>]]) -> [Section<Layout>] {
    components.flatMap { $0 }
  }
}