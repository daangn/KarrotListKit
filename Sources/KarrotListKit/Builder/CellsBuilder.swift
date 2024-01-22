//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Foundation

@resultBuilder
public enum CellsBuilder {
  public static func buildBlock(_ components: Cell...) -> [Cell] {
    components
  }

  public static func buildBlock(_ components: [Cell]) -> [Cell] {
    components
  }

  public static func buildEither(first component: [Cell]) -> [Cell] {
    component
  }

  public static func buildEither(second component: [Cell]) -> [Cell] {
    component
  }
}
