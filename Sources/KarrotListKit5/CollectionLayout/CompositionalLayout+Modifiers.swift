//
//  CompositionalLayout+Modifiers.swift
//  KarrotListKit
//
//  Created by Max.kim on 8/4/25.
//

import UIKit

extension List<CompositionalLayout> {

  public func scrollDirection(_ scrollDirection: UICollectionView.ScrollDirection) -> Self {
    layoutValues.configuration.scrollDirection = scrollDirection
    return self
  }

  public func interSectionSpacing(_ interSectionSpacing: CGFloat) -> Self {
    layoutValues.configuration.interSectionSpacing = interSectionSpacing
    return self
  }

  public func contentInsetsReference(_ contentInsetsReference: UIContentInsetsReference) -> Self {
    layoutValues.configuration.contentInsetsReference = contentInsetsReference
    return self
  }
}

extension Section<CompositionalLayout> {

  public func contentInsets(_ contentInsets: NSDirectionalEdgeInsets) -> Self {
    var copy = self
    copy.layoutValues.configurationHandlers.append { $0.contentInsets = contentInsets }
    return copy
  }

  public func contentInsetsReference(_ contentInsetsReference: UIContentInsetsReference) -> Self {
    var copy = self
    copy.layoutValues.configurationHandlers.append { $0.contentInsetsReference = contentInsetsReference }
    return copy
  }

  public func interGroupSpacing(_ interGroupSpacing: CGFloat) -> Self {
    var copy = self
    copy.layoutValues.configurationHandlers.append { $0.interGroupSpacing = interGroupSpacing }
    return copy
  }
}

extension SupplementaryItem<CompositionalLayout.BoundarySupplementaryItemLayoutValues> {

  // MARK: NSCollectionLayoutItem

  public func edgeSpacing(_ edgeSpacing: NSCollectionLayoutEdgeSpacing?) -> Self {
    var copy = self
    copy.layoutValues.configurationHandlers.append { $0.edgeSpacing = edgeSpacing }
    return copy
  }

  public func contentInsets(_ contentInsets: NSDirectionalEdgeInsets) -> Self {
    var copy = self
    copy.layoutValues.configurationHandlers.append { $0.contentInsets = contentInsets }
    return copy
  }

  // MARK: NSCollectionLayoutSupplementaryItem

  public func zIndex(_ zIndex: Int) -> Self {
    var copy = self
    copy.layoutValues.configurationHandlers.append { $0.zIndex = zIndex }
    return copy
  }

  // MARK: NSCollectionLayoutBoundarySupplementaryItem

  public func pinToVisibleBounds(_ pinToVisibleBounds: Bool) -> Self {
    var copy = self
    copy.layoutValues.configurationHandlers.append { $0.pinToVisibleBounds = pinToVisibleBounds }
    return copy
  }

  public func extendsBoundary(_ extendsBoundary: Bool) -> Self {
    var copy = self
    copy.layoutValues.configurationHandlers.append { $0.extendsBoundary = extendsBoundary }
    return copy
  }
}

extension DecorationItem<CompositionalLayout.DecorationItemLayoutValues> {

  // MARK: NSCollectionLayoutItem

  public func edgeSpacing(_ edgeSpacing: NSCollectionLayoutEdgeSpacing?) -> Self {
    var copy = self
    copy.layoutValues.configurationHandlers.append { $0.edgeSpacing = edgeSpacing }
    return copy
  }

  public func contentInsets(_ contentInsets: NSDirectionalEdgeInsets) -> Self {
    var copy = self
    copy.layoutValues.configurationHandlers.append { $0.contentInsets = contentInsets }
    return copy
  }

  // MARK: NSCollectionLayoutDecorationItem

  public func zIndex(_ zIndex: Int) -> Self {
    var copy = self
    copy.layoutValues.configurationHandlers.append { $0.zIndex = zIndex }
    return copy
  }
}
