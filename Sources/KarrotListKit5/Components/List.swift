import UIKit

struct ListValues {

  @Handler(UICollectionViewDelegate.collectionView(_:targetContentOffsetForProposedContentOffset:))
  var targetContentOffsetForProposedContentOffset = nil

  @Handlers(UICollectionViewDataSourcePrefetching.collectionView(_:prefetchItemsAt:))
  var prefetchItemsAtIndexPaths = []

  @Handlers(UICollectionViewDataSourcePrefetching.collectionView(_:cancelPrefetchingForItemsAt:))
  var cancelPrefetchingForItemsAtIndexPaths = []
}

public struct List<Layout: CollectionLayout> {

  public let sections: [Section<Layout>]
  public let supplementaryItems: [ElementKind: [any SupplementaryItemProtocol]]

  public var layoutValues: Layout.LayoutValues
  var values: ListValues = .init()

  public init(
    sections: [Section<Layout>],
    supplementaryItems: [ElementKind: [any SupplementaryItemProtocol]],
    layoutValues: Layout.LayoutValues,
  ) {
    self.sections = sections
    self.supplementaryItems = supplementaryItems
    self.layoutValues = layoutValues
  }
}

extension List {

  public func targetContentOffsetForProposedContentOffset(
    handler: @escaping (
      _ collectionView: UICollectionView,
      _ proposedContentOffset: CGPoint
    ) -> CGPoint
  ) -> Self {
    var copy = self
    copy.values.targetContentOffsetForProposedContentOffset = handler
    return copy
  }
}

extension List {

  public func prefetchItems(
    handler: @escaping (_ collectionView: UICollectionView, _ indexPaths: [IndexPath]) -> Void
  ) -> Self {
    var copy = self
    copy.values.prefetchItemsAtIndexPaths.append(handler)
    return copy
  }

  public func cancelPrefetchingForItems(
    handler: @escaping (_ collectionView: UICollectionView, _ indexPaths: [IndexPath]) -> Void
  ) -> Self {
    var copy = self
    copy.values.cancelPrefetchingForItemsAtIndexPaths.append(handler)
    return copy
  }

  public func prefetchable(
    action: @escaping (_ indexPaths: [IndexPath]) async -> Void
  ) -> Self {
    var task: Task<Void, Never>?
    return self
      .prefetchItems { collectionView, indexPath in
        task = Task {
          await action(indexPath)
        }
      }
      .cancelPrefetchingForItems { collectionView, indexPath in
        task?.cancel()
      }
  }
}
