import UIKit

public struct FlowLayout: CollectionLayout {

  public struct LayoutValues {
    var scrollDirection: UICollectionView.ScrollDirection = .vertical
    var sectionInsetReference: UICollectionViewFlowLayout.SectionInsetReference = .fromContentInset
    var sectionHeadersPinToVisibleBounds: Bool = false
    var sectionFootersPinToVisibleBounds: Bool = false
    var estimatedItemSize: CGSize = .zero
  }

  public struct SectionLayoutValues {
    var inset: UIEdgeInsets = .zero
    var minimumLineSpacing: CGFloat = 10.0
    var minimumInteritemSpacing: CGFloat = 10.0
    var referenceSizeForHeader: CGSize = .zero
    var referenceSizeForFooter: CGSize = .zero
  }

  public struct ItemLayoutValues {
    var size: CGSize = .init(width: 50.0, height: 50.0)
  }

  public final class Delegate: BaseCollectionViewDelegate<FlowLayout>, UICollectionViewDelegateFlowLayout {

    public func collectionView(
      _ collectionView: UICollectionView,
      layout collectionViewLayout: UICollectionViewLayout,
      sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
      guard let item = item(for: collectionView, at: indexPath) else {
        return (collectionViewLayout as! UICollectionViewFlowLayout).itemSize
      }
      return item.layoutValues.size
    }

    public func collectionView(
      _ collectionView: UICollectionView,
      layout collectionViewLayout: UICollectionViewLayout,
      insetForSectionAt section: Int
    ) -> UIEdgeInsets {
      guard let section = self.section(for: collectionView, at: IndexPath(item: NSNotFound, section: section)) else {
        return (collectionViewLayout as! UICollectionViewFlowLayout).sectionInset
      }
      return section.layoutValues.inset
    }

    public func collectionView(
      _ collectionView: UICollectionView,
      layout collectionViewLayout: UICollectionViewLayout,
      referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
      guard let section = self.section(for: collectionView, at: IndexPath(item: NSNotFound, section: section)) else {
        return (collectionViewLayout as! UICollectionViewFlowLayout).headerReferenceSize
      }
      return section.layoutValues.referenceSizeForHeader
    }
    
    public func collectionView(
      _ collectionView: UICollectionView,
      layout collectionViewLayout: UICollectionViewLayout,
      referenceSizeForFooterInSection section: Int
    ) -> CGSize {
      guard let section = self.section(for: collectionView, at: IndexPath(item: NSNotFound, section: section)) else {
        return (collectionViewLayout as! UICollectionViewFlowLayout).footerReferenceSize
      }
      return section.layoutValues.referenceSizeForFooter
    }
  }

  public static func makeCollectionViewDelegate() -> Delegate {
    .init()
  }

  public static func makeCollectionViewLayout(list: List<FlowLayout>) -> UICollectionViewFlowLayout {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = list.layoutValues.scrollDirection
    layout.sectionInsetReference = list.layoutValues.sectionInsetReference
    layout.sectionHeadersPinToVisibleBounds = list.layoutValues.sectionHeadersPinToVisibleBounds
    layout.sectionFootersPinToVisibleBounds = list.layoutValues.sectionFootersPinToVisibleBounds
    layout.estimatedItemSize = list.layoutValues.estimatedItemSize
    return layout
  }
}

extension List<FlowLayout> {

  public init(
    @SectionsBuilder<Layout> sections: () -> [Section<Layout>]
  ) {
    self.init(
      sections: sections(),
      supplementaryItems: [:],
      layoutValues: .init()
    )
  }
}

extension Section<FlowLayout> {

  public init(
    id: some Hashable,
    @ItemsBuilder<Layout> items: () -> [Item<Layout>],
    header: () -> SupplementaryItem<Void>? = { nil },
    footer: () -> SupplementaryItem<Void>? = { nil }
  ) {
    self.init(
      id: id,
      items: items(),
      supplementaryItems: [
        .sectionHeader: [header()].compactMap(\.self),
        .sectionFooter: [footer()].compactMap(\.self),
      ],
      decorationItems: [:],
      layoutValues: .init()
    )
  }
}

extension Item<FlowLayout> {

  public init<ContentConfigurationType: UIContentConfiguration>(
    id: some Hashable,
    contentConfiguration: () -> ContentConfigurationType
  ) {
    self.init(
      id: id,
      contentConfiguration: contentConfiguration(),
      layoutValues: .init()
    )
  }
}
