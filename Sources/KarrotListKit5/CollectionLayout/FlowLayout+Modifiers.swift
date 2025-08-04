//
//  FlowLayout+Modifiers.swift
//  KarrotListKit
//
//  Created by Max.kim on 8/4/25.
//

import UIKit

extension List<FlowLayout> {

  public func scrollDirection(_ scrollDirection: UICollectionView.ScrollDirection) -> Self {
    var copy = self
    copy.layoutValues.scrollDirection = scrollDirection
    return copy
  }

  public func sectionInsetReference(_ sectionInsetReference: UICollectionViewFlowLayout.SectionInsetReference) -> Self {
    var copy = self
    copy.layoutValues.sectionInsetReference = sectionInsetReference
    return copy
  }

  public func sectionHeadersPinToVisibleBounds(_ sectionHeadersPinToVisibleBounds: Bool) -> Self {
    var copy = self
    copy.layoutValues.sectionHeadersPinToVisibleBounds = sectionHeadersPinToVisibleBounds
    return copy
  }

  public func sectionFootersPinToVisibleBounds(_ sectionFootersPinToVisibleBounds: Bool) -> Self {
    var copy = self
    copy.layoutValues.sectionFootersPinToVisibleBounds = sectionFootersPinToVisibleBounds
    return copy
  }

  public func estimatedItemSize(_ estimatedItemSize: CGSize) -> Self {
    var copy = self
    copy.layoutValues.estimatedItemSize = estimatedItemSize
    return copy
  }
}

extension Section<FlowLayout> {

  public func inset(_ inset: UIEdgeInsets) -> Self {
    var copy = self
    copy.layoutValues.inset = inset
    return copy
  }

  public func minimumLineSpacing(_ minimumLineSpacing: CGFloat) -> Self {
    var copy = self
    copy.layoutValues.minimumLineSpacing = minimumLineSpacing
    return copy
  }

  public func minimumInteritemSpacing(_ minimumInteritemSpacing: CGFloat) -> Self {
    var copy = self
    copy.layoutValues.minimumInteritemSpacing = minimumInteritemSpacing
    return copy
  }

  public func referenceSizeForHeader(_ referenceSize: CGSize) -> Self {
    var copy = self
    copy.layoutValues.referenceSizeForHeader = referenceSize
    return copy
  }

  public func referenceSizeForFooter(_ referenceSize: CGSize) -> Self {
    var copy = self
    copy.layoutValues.referenceSizeForFooter = referenceSize
    return copy
  }
}

extension Item<FlowLayout> {

  public func size(_ size: CGSize) -> Self {
    var copy = self
    copy.layoutValues.size = size
    return copy
  }
}

