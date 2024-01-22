//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Foundation

extension Collection {

  subscript(safe index: Index) -> Element? {
    indices.contains(index) ? self[index] : nil
  }
}
