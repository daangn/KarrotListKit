import UIKit

public protocol SupplementaryItemProtocol<LayoutValues> {
  associatedtype LayoutValues
  var reuseIdentifier: String { get }
  var contentConfiguration: UIContentConfiguration { get }
  var layoutValues: LayoutValues { get }
}

struct SupplementaryItemValues {

  @Handlers(UICollectionViewDelegate.collectionView(_:willDisplaySupplementaryView:forElementKind:at:))
  var willDisplaySupplementaryViewForElementKindAtIndexPath = []

  @Handlers(UICollectionViewDelegate.collectionView(_:didEndDisplayingSupplementaryView:forElementOfKind:at:))
  var didEndDisplayingSupplementaryViewForElementOfKindAtIndexPath = []
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
    copy.values.willDisplaySupplementaryViewForElementKindAtIndexPath.append(handler)
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
    copy.values.didEndDisplayingSupplementaryViewForElementOfKindAtIndexPath.append(handler)
    return copy
  }
}
