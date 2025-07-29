//
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import UIKit

/// A protocol that defines the layout strategy for a list.
/// Each layout implementation provides its own section layout type.
public protocol ListLayout {
  /// The type of section layout provider used by this list layout.
  associatedtype SectionLayout

  static func makeCollectionViewLayout(
    sections: [Section<SectionLayout>]
  ) -> UICollectionViewLayout
}
