import UIKit

public final class CollectionViewAdapter<
  CollectionLayoutType: CollectionLayout
>: NSObject, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {

  private let defaultReuseIdentifier = "defaultReuseIdentifier"

  public let collectionView: UICollectionView
  private let collectionViewDelegate = CollectionLayoutType.makeCollectionViewDelegate()

  public private(set) var list: List<CollectionLayoutType>? {
    didSet {
      guard let list else {
        collectionView.collectionViewLayout = .init()
        return
      }

      collectionView.collectionViewLayout = CollectionLayoutType.makeCollectionViewLayout(list: list)

      for section in list.sections {
        for item in section.items {
          collectionView.register(
            UICollectionViewCell.self,
            forCellWithReuseIdentifier: item.reuseIdentifier
          )
        }
        for (elementKind, supplementaryItems) in section.supplementaryItems {
          for supplementaryItem in supplementaryItems {
            collectionView.register(
              UICollectionViewCell.self,
              forSupplementaryViewOfKind: elementKind.rawValue,
              withReuseIdentifier: supplementaryItem.reuseIdentifier
            )
            collectionView.register(
              UICollectionReusableView.self,
              forSupplementaryViewOfKind: elementKind.rawValue,
              withReuseIdentifier: defaultReuseIdentifier
            )
          }
        }
        for (elementKind, decorationItems) in section.decorationItems {
          for decorationItem in decorationItems {
            collectionView.collectionViewLayout.register(
              decorationItem.viewClass,
              forDecorationViewOfKind: elementKind.rawValue
            )
          }
        }
      }
      for (elementKind, supplementaryItems) in list.supplementaryItems {
        for supplementaryItem in supplementaryItems {
          collectionView.register(
            UICollectionViewCell.self,
            forSupplementaryViewOfKind: elementKind.rawValue,
            withReuseIdentifier: supplementaryItem.reuseIdentifier
          )
          collectionView.register(
            UICollectionReusableView.self,
            forSupplementaryViewOfKind: elementKind.rawValue,
            withReuseIdentifier: defaultReuseIdentifier
          )
        }
      }
    }
  }

  public init(
    collectionView: UICollectionView = .init(
      frame: .zero,
      collectionViewLayout: UICollectionViewLayout()
    )
  ) {
    self.collectionView = collectionView
    super.init()
    self.collectionView.dataSource = self
    self.collectionView.prefetchDataSource = self
    self.collectionView.delegate = collectionViewDelegate
  }

  public func apply(
    list: List<CollectionLayoutType>,
    completion: ((Bool) -> Void)? = nil
  ) {
    self.list = list
    collectionView.performBatchUpdates(nil, completion: completion)
  }

  // MARK: UICollectionViewDataSource

  public func numberOfSections(
    in collectionView: UICollectionView
  ) -> Int {
    guard let list else { return 0 }
    return list.sections.count
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    guard let list else { return 0 }
    return list.sections[section].items.count
  }

  // FIXME: safe subscript 처리 필요
  public func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    guard let item = list?.sections[indexPath.section].items[indexPath.item] else { return .init() }
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item.reuseIdentifier, for: indexPath)
    cell.contentConfiguration = item.contentConfiguration
    // FIXME: Item에서 backgroundConfiguration도 관리할 수 있는 방향 고민하기
    cell.backgroundConfiguration = .listPlainCell()
    return cell
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    viewForSupplementaryElementOfKind kind: String,
    at indexPath: IndexPath
  ) -> UICollectionReusableView {
    /// `IndexPath[section, NSNotFound]`(글로벌 헤더)는 `Section`보다 상위인 `List`에서 관리해야 하고,
    /// `IndexPath[section, item]`(섹션 헤더)는 `Item`보다 상위인 `Section`에서 관리해야 한다.
    ///
    /// 근거 1: 섹션 헤더는 아이템의 개수가 0개이더라도 표시가 된다. 따라서 `Item`에 묶을 수 없다.
    /// 근거 2: 섹션 헤더는 섹션이 0개일 때 표시되지 않는다. 따라서 `Section` 상위에 묶어야 한다.
    /// 근거 3: 글로벌 헤더는 섹션이 0개일 때도 표시가 된다. 따라서 `Section`에 묶을 수 없다.
    /// 근거 4: Compositional Layout에서 NSCollectionLayoutItem 하위 NSCollectionLayoutSupplementaryItem과 NSCollectionLayoutSection 하위 NSCollectionLayoutBoundarySupplementaryItem의 elementKind가 중복이면 크래시가 발생하지만, NSCollectionLayoutSection 하위 NSCollectionLayoutBoundarySupplementaryItem과 UICollectionViewCompositionalLayout 하위 NSCollectionLayoutBoundarySupplementaryItem의 elementKind가 중복일 때는 크래시가 발생하지 않는다. 이는 supplementaryItems가 [section, NSNotFound] 와 [section, item] 에 대해 따로 관리된다는 것을 의미한다.

    let supplementaryItem = if indexPath.item == NSNotFound {
      list?
        .supplementaryItems[ElementKind(rawValue: kind)]?[indexPath.section]
    } else {
      list?
        .sections[indexPath.section]
        .supplementaryItems[ElementKind(rawValue: kind)]?[indexPath.item]
    }
    guard
      let supplementaryItem,
      let cell = collectionView.dequeueReusableSupplementaryView(
        ofKind: kind,
        withReuseIdentifier: supplementaryItem.reuseIdentifier,
        for: indexPath
      ) as? UICollectionViewCell
    else {
      let supplementaryView = collectionView.dequeueReusableSupplementaryView(
        ofKind: kind,
        withReuseIdentifier: defaultReuseIdentifier,
        for: indexPath
      )
      return supplementaryView
    }
    cell.contentConfiguration = supplementaryItem.contentConfiguration
    return cell
  }

  // MARK: UICollectionViewDataSourcePrefetching

  public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
    list?.values.prefetchItemsAtIndexPaths.forEach {
      $0(collectionView, indexPaths)
    }
    for indexPath in indexPaths {
      list?.sections[indexPath.section].items[indexPath.item].values.prefetchItemAtIndexPath.forEach {
        $0(collectionView, indexPath)
      }
    }
  }

  public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
    list?.values.cancelPrefetchingForItemsAtIndexPaths.forEach {
      $0(collectionView, indexPaths)
    }
    for indexPath in indexPaths {
      list?.sections[indexPath.section].items[indexPath.item].values.cancelPrefetchingForItemAtIndexPath.forEach {
        $0(collectionView, indexPath)
      }
    }
  }
}
