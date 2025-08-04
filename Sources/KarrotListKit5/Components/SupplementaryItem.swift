import UIKit

public protocol SupplementaryItemProtocol<LayoutValues> {
  associatedtype LayoutValues
  var reuseIdentifier: String { get }
  var contentConfiguration: UIContentConfiguration { get }
  var layoutValues: LayoutValues { get }
}

struct SupplementaryItemValues {
  var willDisplaySupplementaryViewForElementKindAtIndexPath: (
    (
      _ collectionView: UICollectionView,
      _ view: UICollectionReusableView,
      _ elementKind: String,
      _ indexPath: IndexPath
    ) -> Void
  )?
  var didEndDisplayingSupplementaryViewForElementOfKindAtIndexPath: (
    (
      _ collectionView: UICollectionView,
      _ view: UICollectionReusableView,
      _ elementKind: String,
      _ indexPath: IndexPath
    ) -> Void
  )?
}

public struct SupplementaryItem<LayoutValues>: SupplementaryItemProtocol {

  public let reuseIdentifier: String
  public let contentConfiguration: UIContentConfiguration

  public var layoutValues: LayoutValues
  var values: SupplementaryItemValues = .init()

  public init<ContentConfigurationType: UIContentConfiguration>(
    contentConfiguration: ContentConfigurationType,
    layoutValues: LayoutValues
  ) {
    self.reuseIdentifier = String(describing: ContentConfigurationType.self)
    self.contentConfiguration = contentConfiguration
    self.layoutValues = layoutValues
  }

  public init<ContentConfigurationType: UIContentConfiguration>(
    contentConfiguration: () -> ContentConfigurationType
  ) where LayoutValues == Void {
    self.init(
      contentConfiguration: contentConfiguration(),
      layoutValues: ()
    )
  }
}

extension SupplementaryItem {

  public func willDisplaySupplementaryView(
    handler: @escaping (
      _ collectionView: UICollectionView,
      _ view: UICollectionReusableView,
      _ elementKind: String,
      _ indexPath: IndexPath
    ) -> Void
  ) -> Self {
    var copy = self
    copy.values.willDisplaySupplementaryViewForElementKindAtIndexPath = handler
    return copy
  }

  public func didEndDisplayingSupplementaryView(
    handler: @escaping (
      _ collectionView: UICollectionView,
      _ view: UICollectionReusableView,
      _ elementKind: String,
      _ indexPath: IndexPath
    ) -> Void
  ) -> Self {
    var copy = self
    copy.values.didEndDisplayingSupplementaryViewForElementOfKindAtIndexPath = handler
    return copy
  }
}
