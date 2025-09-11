//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Foundation

#if canImport(UIKit)
import CoreGraphics

/// An enumeration that defines how a `Component`'s content should be laid out in a `UICollectionView`.
public enum ContentLayoutMode: Equatable {

  /// The content's width and height are adjusted to fit the size of the parent container.
  case fitContainer

  /// The content's width is determined by the parent container, and its height is adjusted to fit the size of the content itself.
  /// An estimated height is provided for use before the actual height is calculated.
  ///
  /// - Parameter estimatedHeight: The estimated height of the content.
  case flexibleHeight(estimatedHeight: CGFloat)

  /// The content's height is determined by the parent container, and its width is adjusted to fit the size of the content itself.
  /// An estimated width is provided for use before the actual width is calculated.
  ///
  /// - Parameter estimatedWidth: The estimated width of the content.
  case flexibleWidth(estimatedWidth: CGFloat)

  /// Both the content's width and height are adjusted to fit the size of the content itself.
  /// An estimated size is provided for use before the actual size is calculated.
  ///
  /// - Parameter estimatedSize: The estimated size of the content.
  case fitContent(estimatedSize: CGSize)
}
#endif
