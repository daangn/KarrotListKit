//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

/// A protocol that manage data and size information for List
///
/// A data source object manages the data in your collection view.
/// Additionally, the data source object should be able to cache and manage size information for cells / supplementary views.
///
/// - Note: `CollectionViewAdapter` conform this protocol and manages data and size information internally.
///  so we generally do not implement this protocol.
public protocol CollectionViewLayoutAdapterDataSource: AnyObject {

  /// Returns the section at the index.
  /// - Parameter index: The index of the section to return.
  /// - Returns: The section at the index.
  func sectionItem(at index: Int) -> Section?
}

/// The `CollectionViewLayoutAdaptable` interface serves as an adapter between the UICollectionViewCompositionalLayout logic and the `KarrotListKit` layout logic
///
/// The sectionProvider in `UICollectionViewCompositionalLayout.init(sectionProvider: @escaping UICollectionViewCompositionalLayoutSectionProvider)` is mapped to the sectionLayout method in the interface.
/// We can implement `UICollectionViewCompositionalLayout` through the implementation of the sectionLayout method.
///
/// - Note: `CollectionViewLayoutAdapter` conform this protocol so we generally do not implement this protocol.
public protocol CollectionViewLayoutAdaptable: AnyObject {

  /// The data source needed to create NSCollectionLayoutSection.
  var dataSource: CollectionViewLayoutAdapterDataSource? { get set }

  /// The method to create NSCollectionLayoutSection.
  /// - Parameters:
  ///   - index: The index of the section to create.
  ///   - environment: The layout environment information.
  /// - Returns: The created NSCollectionLayoutSection.
  func sectionLayout(
    index: Int,
    environment: NSCollectionLayoutEnvironment
  ) -> NSCollectionLayoutSection?
}

/// This object is the default implementation for CollectionViewLayoutAdaptable.
///
/// The initialize has been extended to accept CollectionViewLayoutAdaptable at the time of UICollectionView.init.
/// If you want to inject UICollectionViewCompositionalLayout directly, please refer to the code below.
/// ```swift
/// UICollectionView(
///   frame: .zero,
///   collectionViewLayout: UICollectionViewCompositionalLayout(
///    sectionProvider: layoutAdapter.sectionLayout
///   )
/// )
/// ```
public class CollectionViewLayoutAdapter: CollectionViewLayoutAdaptable {

  /// The data source needed to create NSCollectionLayoutSection.
  public weak var dataSource: CollectionViewLayoutAdapterDataSource?

  public init() {}

  /// The method to create NSCollectionLayoutSection.
  /// - Parameters:
  ///   - index: The index of the section to create.
  ///   - environment: The layout environment information.
  /// - Returns: The created NSCollectionLayoutSection.
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
      environment: environment
    )
  }
}
