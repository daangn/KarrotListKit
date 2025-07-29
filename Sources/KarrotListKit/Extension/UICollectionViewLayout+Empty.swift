//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

extension UICollectionViewLayout {

  public static var empty: UICollectionViewLayout {
    EmptyCollectionViewLayout()
  }
}

public class EmptyCollectionViewLayout: UICollectionViewLayout {}
