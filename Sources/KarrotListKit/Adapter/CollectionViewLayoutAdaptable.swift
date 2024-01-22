//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

public protocol CollectionViewLayoutAdapterDataSource: AnyObject {
  func sectionItem(at index: Int) -> Section?
  func sizeStorage() -> ComponentSizeStorage
}

public protocol CollectionViewLayoutAdaptable: AnyObject {
  var dataSource: CollectionViewLayoutAdapterDataSource? { get set }

  func sectionLayout(
    index: Int,
    environment: NSCollectionLayoutEnvironment
  ) -> NSCollectionLayoutSection?
}

public class CollectionViewLayoutAdapter: CollectionViewLayoutAdaptable {
  public weak var dataSource: CollectionViewLayoutAdapterDataSource?

  public init() {}

  public func sectionLayout(
    index: Int,
    environment: NSCollectionLayoutEnvironment
  ) -> NSCollectionLayoutSection? {
    guard let dataSource else {
      return nil
    }

    guard let sectionItem = dataSource.sectionItem(at: index), !sectionItem.cells.isEmpty else {
      return nil
    }

    return sectionItem.layout(
      index: index,
      environment: environment,
      sizeStorage: dataSource.sizeStorage()
    )
  }
}
