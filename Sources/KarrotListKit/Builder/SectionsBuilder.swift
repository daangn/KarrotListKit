//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Foundation

@resultBuilder
public enum SectionsBuilder {
  public static func buildBlock(_ component: Section...) -> [Section] {
    component
  }

  public static func buildBlock(_ component: [Section]) -> [Section] {
    component
  }
}
