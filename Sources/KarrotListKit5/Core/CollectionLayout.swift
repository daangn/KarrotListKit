import UIKit

public protocol CollectionLayout {
  associatedtype LayoutValues = Void
  associatedtype SectionLayoutValues = Void
  associatedtype ItemLayoutValues = Void
  associatedtype CollectionViewLayoutType: UICollectionViewLayout
  associatedtype CollectionViewDelegateType: BaseCollectionViewDelegate<Self> = BaseCollectionViewDelegate<Self>
  static func makeCollectionViewDelegate() -> CollectionViewDelegateType
  static func makeCollectionViewLayout(list: List<Self>) -> CollectionViewLayoutType
}

extension CollectionLayout where CollectionViewDelegateType == BaseCollectionViewDelegate<Self> {
  public static func makeCollectionViewDelegate() -> CollectionViewDelegateType { .init() }
}

open class BaseCollectionViewDelegate<Layout: CollectionLayout>: NSObject, UICollectionViewDelegate {

  // MARK: Utilities

  public func adapter(
    for collectionView: UICollectionView
  ) -> CollectionViewAdapter<Layout>? {
    collectionView.dataSource as? CollectionViewAdapter<Layout>
  }

  public func list(
    for collectionView: UICollectionView
  ) -> List<Layout>? {
    adapter(for: collectionView)?.list
  }

  public func section(
    for collectionView: UICollectionView,
    at indexPath: IndexPath
  ) -> Section<Layout>? {
    list(for: collectionView)?.sections[indexPath.section]
  }

  public func item(
    for collectionView: UICollectionView,
    at indexPath: IndexPath
  ) -> Item<Layout>? {
    section(for: collectionView, at: indexPath)?.items[indexPath.item]
  }

  // MARK: Item

  public func collectionView(
    _ collectionView: UICollectionView,
    didSelectItemAt indexPath: IndexPath
  ) {
    item(for: collectionView, at: indexPath)?.values.didSelectItemAtIndexPath.forEach {
      $0(collectionView, indexPath)
    }
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    didDeselectItemAt indexPath: IndexPath
  ) {
    item(for: collectionView, at: indexPath)?.values.didDeselectItemAtIndexPath.forEach {
      $0(collectionView, indexPath)
    }
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    willDisplay cell: UICollectionViewCell,
    forItemAt indexPath: IndexPath
  ) {
    item(for: collectionView, at: indexPath)?.values.willDisplayCellForItemAtIndexPath.forEach {
      $0(collectionView, cell, indexPath)
    }
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    didEndDisplaying cell: UICollectionViewCell,
    forItemAt indexPath: IndexPath
  ) {
    item(for: collectionView, at: indexPath)?.values.didEndDisplayingCellForItemAtIndexPath.forEach {
      $0(collectionView, cell, indexPath)
    }
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    canPerformPrimaryActionForItemAt indexPath: IndexPath
  ) -> Bool {
    item(for: collectionView, at: indexPath)?.values.canPerformPrimaryActionForItemAtIndexPath?(collectionView, indexPath) ?? true
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    performPrimaryActionForItemAt indexPath: IndexPath
  ) {
    item(for: collectionView, at: indexPath)?.values.performPrimaryActionForItemAtIndexPath.forEach {
      $0(collectionView, indexPath)
    }
  }

  // MARK: List

  public func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
    list(for: collectionView)?.values.targetContentOffsetForProposedContentOffset?(collectionView, proposedContentOffset) ?? proposedContentOffset
  }
}
