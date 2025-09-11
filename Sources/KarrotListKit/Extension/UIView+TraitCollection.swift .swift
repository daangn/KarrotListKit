//
//  Copyright (c) 2025 Danggeun Market Inc.
//

#if canImport(UIKit)
import UIKit

extension UIView {

  func shouldInvalidateContentSize(
    previousTraitCollection: UITraitCollection?
  ) -> Bool {
    if traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory {
      return true
    }

    if traitCollection.legibilityWeight != previousTraitCollection?.legibilityWeight {
      return true
    }

    if traitCollection.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass ||
        traitCollection.verticalSizeClass != previousTraitCollection?.verticalSizeClass {
      return true
    }

    return false
  }
}
#endif
