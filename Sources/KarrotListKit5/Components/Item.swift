import UIKit

struct ItemValues {

  @Handlers(UICollectionViewDelegate.collectionView(_:didSelectItemAt:))
  var didSelectItemAtIndexPath = []

  @Handlers(UICollectionViewDelegate.collectionView(_:didDeselectItemAt:))
  var didDeselectItemAtIndexPath = []

  @Handlers(UICollectionViewDelegate.collectionView(_:willDisplay:forItemAt:))
  var willDisplayCellForItemAtIndexPath = []

  @Handlers(UICollectionViewDelegate.collectionView(_:didEndDisplaying:forItemAt:))
  var didEndDisplayingCellForItemAtIndexPath = []

  @Handler(UICollectionViewDelegate.collectionView(_:canPerformPrimaryActionForItemAt:))
  var canPerformPrimaryActionForItemAtIndexPath = nil

  @Handlers(UICollectionViewDelegate.collectionView(_:performPrimaryActionForItemAt:))
  var performPrimaryActionForItemAtIndexPath = []

  var prefetchItemAtIndexPath: [(_ collectionView: UICollectionView, _ indexPath: IndexPath) -> Void] = []
  var cancelPrefetchingForItemAtIndexPath: [(_ collectionView: UICollectionView, _ indexPath: IndexPath) -> Void] = []
}

public struct Item<Layout: CollectionLayout> {

  internal let reuseIdentifier: String
  public let id: AnyHashable
  public let contentConfiguration: UIContentConfiguration
  
  public var layoutValues: Layout.ItemLayoutValues
  var values: ItemValues = .init()

  public init<ContentConfigurationType: UIContentConfiguration>(
    id: some Hashable,
    contentConfiguration: ContentConfigurationType,
    layoutValues: Layout.ItemLayoutValues
  ) {
    self.reuseIdentifier = String(describing: ContentConfigurationType.self)
    self.id = id
    self.contentConfiguration = contentConfiguration
    self.layoutValues = layoutValues
  }

  public init<ContentConfigurationType: UIContentConfiguration>(
    id: some Hashable,
    contentConfiguration: () -> ContentConfigurationType
  ) where Layout.ItemLayoutValues == Void {
    self.init(
      id: id,
      contentConfiguration: contentConfiguration(),
      layoutValues: ()
    )
  }
}

extension Item {

  public func didSelect(
    handler: @escaping (_ collectionView: UICollectionView, _ indexPath: IndexPath) -> Void
  ) -> Self {
    var copy = self
    copy.values.didSelectItemAtIndexPath.append(handler)
    return copy
  }

  public func didDeselect(
    handler: @escaping (_ collectionView: UICollectionView, _ indexPath: IndexPath) -> Void
  ) -> Self {
    var copy = self
    copy.values.didDeselectItemAtIndexPath.append(handler)
    return copy
  }

  public func willDisplayCell(
    handler: @escaping (_ collectionView: UICollectionView, _ cell: UICollectionViewCell, _ indexPath: IndexPath) -> Void
  ) -> Self {
    var copy = self
    copy.values.willDisplayCellForItemAtIndexPath.append(handler)
    return copy
  }

  public func didEndDisplayingCell(
    handler: @escaping (_ collectionView: UICollectionView, _ cell: UICollectionViewCell, _ indexPath: IndexPath) -> Void
  ) -> Self {
    var copy = self
    copy.values.didEndDisplayingCellForItemAtIndexPath.append(handler)
    return copy
  }

  public func canPerformPrimaryAction(_ canPerformPrimaryAction: Bool) -> Self {
    var copy = self
    copy.values.canPerformPrimaryActionForItemAtIndexPath = { _, _ in canPerformPrimaryAction }
    return copy
  }

  public func performPrimaryAction(_ primaryAction: @escaping () -> Void) -> Self {
    var copy = self
    copy.values.performPrimaryActionForItemAtIndexPath.append({ _, _ in primaryAction() })
    return copy
  }
}

extension Item {

  public func prefetch(
    handler: @escaping (_ collectionView: UICollectionView, _ indexPath: IndexPath) -> Void
  ) -> Self {
    var copy = self
    copy.values.prefetchItemAtIndexPath.append(handler)
    return copy
  }

  public func cancelPrefetching(
    handler: @escaping (_ collectionView: UICollectionView, _ indexPath: IndexPath) -> Void
  ) -> Self {
    var copy = self
    copy.values.cancelPrefetchingForItemAtIndexPath.append(handler)
    return copy
  }

  public func prefetchable(
    action: @escaping (_ indexPath: IndexPath) async -> Void
  ) -> Self {
    var task: Task<Void, Never>?
    return self
      .prefetch { collectionView, indexPath in
        task = Task {
          await action(indexPath)
        }
      }
      .cancelPrefetching { collectionView, indexPath in
        task?.cancel()
      }
  }
}
