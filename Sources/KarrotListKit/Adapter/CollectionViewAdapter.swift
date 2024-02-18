//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Combine
import UIKit

import DifferenceKit

final public class CollectionViewAdapter: NSObject {
  public var configuration: CollectionViewAdapterConfiguration

  private var registeredCellReuseIdentifiers = Set<String>()
  private var registeredHeaderReuseIdentifiers = Set<String>()
  private var registeredFooterReuseIdentifiers = Set<String>()

  private weak var collectionView: UICollectionView?

  private var prefetchingIndexPathOperations = [IndexPath: [AnyCancellable]]()
  private let prefetchingPlugins: [CollectionViewPrefetchingPlugin]

  private var isUpdating = false
  private var queuedUpdate: (
    list: List,
    animatingDifferences: Bool,
    completion: (() -> Void)?
  )?

  private var componentSizeStorage = ComponentSizeStorageImpl()

  private var list: List?

  private lazy var pullToRefreshControl = UIRefreshControl().then {
    $0.tintColor = configuration.refreshControl.tintColor
    $0.addTarget(
      self,
      action: #selector(pullToRefresh),
      for: .valueChanged
    )
  }

  // MARK: - Initializer

  public init(
    configuration: CollectionViewAdapterConfiguration,
    collectionView: UICollectionView,
    layoutAdapter: CollectionViewLayoutAdaptable,
    prefetchingPlugins: [CollectionViewPrefetchingPlugin] = []
  ) {
    self.configuration = configuration
    self.prefetchingPlugins = prefetchingPlugins

    super.init()

    self.collectionView = collectionView
    collectionView.delegate = self
    collectionView.dataSource = self
    layoutAdapter.dataSource = self

    if prefetchingPlugins.isEmpty == false {
      collectionView.prefetchDataSource = self
    }

    if configuration.refreshControl.isEnabled {
      collectionView.refreshControl = pullToRefreshControl
    }
  }

  // MARK: - Public Methods

  public func apply(
    _ list: List,
    animatingDifferences: Bool = true,
    completion: (() -> Void)? = nil
  ) {
    guard let collectionView else {
      return
    }

    guard isUpdating == false else {
      queuedUpdate = (list, animatingDifferences, completion)
      return
    }

    isUpdating = true

    let overridedCompletion: (Bool) -> Void = { [weak self] _ in
      guard let self else {
        return
      }

      completion?()

      collectionView.indexPathsForVisibleItems.forEach(handleNextBatchIfNeeded)

      if let nextUpdate = queuedUpdate, collectionView.window != nil {
        queuedUpdate = nil
        isUpdating = false
        apply(
          nextUpdate.list,
          animatingDifferences: nextUpdate.animatingDifferences,
          completion: nextUpdate.completion
        )
      } else {
        isUpdating = false
      }
    }

    registerReuseIdentifiers(with: list.sections)

    if self.list == nil || self.list?.sections.count == 0 {
      self.list = list
      collectionView.reloadData()
      collectionView.layoutIfNeeded()
      // 최초 업데이트 이후 최빈값 사이즈를 사용하여 contentSize를 재계산 하는 로직을 수행합니다.
      collectionView.collectionViewLayout.invalidateLayout()
      overridedCompletion(true)
      return
    }

    CATransaction.begin()
    CATransaction.setDisableActions(true)
    if animatingDifferences {
      performDifferentialUpdates(
        old: self.list, new: list, completion: { flag in
          CATransaction.commit()
          overridedCompletion(flag)
        }
      )
    } else {
      UIView.performWithoutAnimation {
        performDifferentialUpdates(
          old: self.list, new: list, completion: { flag in
            CATransaction.commit()
            overridedCompletion(flag)
          }
        )
      }
    }
  }

  // MARK: - Private Methods

  private func performDifferentialUpdates(
    old: List?,
    new: List?,
    completion: @escaping (Bool) -> Void
  ) {
    let changeset = StagedChangeset(
      source: old?.sections ?? [],
      target: new?.sections ?? []
    )

    collectionView?.reload(
      using: changeset,
      interrupt: { $0.changeCount > self.configuration.batchUpdateInterruptCount },
      setData: { sections in
        list?.sections = sections
      },
      completion: completion
    )
  }

  private func registerReuseIdentifiers(with sections: [Section]) {
    sections.forEach { section in
      if let headerReuseIdentifier = section.header?.component.reuseIdentifier,
         !registeredHeaderReuseIdentifiers.contains(headerReuseIdentifier) {
        registeredHeaderReuseIdentifiers.insert(headerReuseIdentifier)
        collectionView?.register(
          UICollectionComponentReusableView.self,
          forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
          withReuseIdentifier: headerReuseIdentifier
        )
      }

      if let footerReuseIdentifier = section.footer?.component.reuseIdentifier,
         !registeredFooterReuseIdentifiers.contains(footerReuseIdentifier) {
        registeredFooterReuseIdentifiers.insert(footerReuseIdentifier)
        collectionView?.register(
          UICollectionComponentReusableView.self,
          forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
          withReuseIdentifier: footerReuseIdentifier
        )
      }

      let cellReuseIdentifiers = Set(section.cells.map { $0.component.reuseIdentifier })
      cellReuseIdentifiers.subtracting(registeredCellReuseIdentifiers).forEach { cellReuseIdentifier in
        registeredCellReuseIdentifiers.insert(cellReuseIdentifier)
        collectionView?.register(
          UICollectionViewComponentCell.self,
          forCellWithReuseIdentifier: cellReuseIdentifier
        )
      }
    }
  }

  private func item(at indexPath: IndexPath) -> Cell? {
    sectionItem(at: indexPath.section)?.cells[safe: indexPath.item]
  }

  private func handleNextBatchIfNeeded(indexPath: IndexPath) {
    guard let section = sectionItem(at: indexPath.section),
          let trigger = section.nextBatchTrigger,
          trigger.context.state == .pending
    else {
      return
    }

    guard trigger.threshold >= section.cells.count - indexPath.item else {
      return
    }

    trigger.context.state = .triggered
    trigger.handler(trigger.context)
  }

  // MARK: - Action Methods

  @objc
  private func pullToRefresh() {
    list?.event(for: PullToRefreshEvent.self)?.handler(.init())
  }
}

// MARK: - CollectionViewLayoutAdapterDataSource

extension CollectionViewAdapter: CollectionViewLayoutAdapterDataSource {
  public func sectionItem(at index: Int) -> Section? {
    list?.sections[safe: index]
  }

  public func sizeStorage() -> ComponentSizeStorage {
    componentSizeStorage
  }
}

// MARK: - UICollectionViewDelegate

extension CollectionViewAdapter: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let item = item(at: indexPath) else {
      return
    }

    item.event(for: DidSelectEvent.self)?.handler(
      .init(
        indexPath: indexPath,
        anyComponent: item.component
      )
    )
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    willDisplay cell: UICollectionViewCell,
    forItemAt indexPath: IndexPath
  ) {
    guard cell.isValidSize() else { return }

    guard let item = item(at: indexPath) else {
      return
    }

    if !isUpdating {
      handleNextBatchIfNeeded(indexPath: indexPath)
    }

    item.event(for: WillDisplayEvent.self)?.handler(
      .init(
        indexPath: indexPath,
        anyComponent: item.component,
        content: (cell as? ComponentRenderable)?.renderedContent
      )
    )
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    didEndDisplaying cell: UICollectionViewCell,
    forItemAt indexPath: IndexPath
  ) {
    guard cell.isValidSize() else { return }

    guard let item = item(at: indexPath) else {
      return
    }

    item.event(for: DidEndDisplayEvent.self)?.handler(
      .init(
        indexPath: indexPath,
        anyComponent: item.component,
        content: (cell as? ComponentRenderable)?.renderedContent
      )
    )
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    willDisplaySupplementaryView view: UICollectionReusableView,
    forElementKind elementKind: String,
    at indexPath: IndexPath
  ) {
    guard view.isValidSize() else { return }

    guard let section = sectionItem(at: indexPath.section) else {
      return
    }

    switch elementKind {
    case UICollectionView.elementKindSectionHeader:
      guard let header = section.header else {
        return
      }
      header.event(for: WillDisplayEvent.self)?.handler(
        .init(
          indexPath: indexPath,
          anyComponent: header.component,
          content: (view as? ComponentRenderable)?.renderedContent
        )
      )
    case UICollectionView.elementKindSectionFooter:
      guard let footer = section.footer else {
        return
      }
      footer.event(for: WillDisplayEvent.self)?.handler(
        .init(
          indexPath: indexPath,
          anyComponent: footer.component,
          content: (view as? ComponentRenderable)?.renderedContent
        )
      )
    default:
      return
    }
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    didEndDisplayingSupplementaryView view: UICollectionReusableView,
    forElementOfKind elementKind: String,
    at indexPath: IndexPath
  ) {
    guard view.isValidSize() else { return }

    guard let section = sectionItem(at: indexPath.section) else {
      return
    }

    switch elementKind {
    case UICollectionView.elementKindSectionHeader:
      guard let header = section.header else {
        return
      }
      header.event(for: DidEndDisplayingEvent.self)?.handler(
        .init(
          indexPath: indexPath,
          anyComponent: header.component,
          content: (view as? ComponentRenderable)?.renderedContent
        )
      )
    case UICollectionView.elementKindSectionFooter:
      guard let footer = section.footer else {
        return
      }
      footer.event(for: DidEndDisplayingEvent.self)?.handler(
        .init(
          indexPath: indexPath,
          anyComponent: footer.component,
          content: (view as? ComponentRenderable)?.renderedContent
        )
      )
    default:
      return
    }
  }
}

// MARK: - UIScrollViewDelegate

extension CollectionViewAdapter {
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard let collectionView else {
      return
    }

    list?.event(for: DidScrollEvent.self)?.handler(
      .init(
        collectionView: collectionView
      )
    )
  }

  public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    guard let collectionView else {
      return
    }

    list?.event(for: WillBeginDraggingEvent.self)?.handler(
      .init(
        collectionView: collectionView
      )
    )
  }

  public func scrollViewWillEndDragging(
    _ scrollView: UIScrollView,
    withVelocity velocity: CGPoint,
    targetContentOffset: UnsafeMutablePointer<CGPoint>
  ) {
    guard let collectionView else {
      return
    }

    list?.event(for: WillEndDraggingEvent.self)?.handler(
      .init(
        collectionView: collectionView,
        velocity: velocity,
        targetContentOffset: targetContentOffset
      )
    )
  }
}

// MARK: - UICollectionViewDataSourcePrefetching

extension CollectionViewAdapter: UICollectionViewDataSourcePrefetching {
  public func collectionView(
    _ collectionView: UICollectionView,
    prefetchItemsAt indexPaths: [IndexPath]
  ) {
    for indexPath in indexPaths {
      guard prefetchingIndexPathOperations[indexPath] == nil else {
        continue
      }

      guard let item = item(at: indexPath),
            let prefetchableComponent = item.component.as(ComponentResourcePrefetchable.self)
      else {
        continue
      }

      prefetchingIndexPathOperations[indexPath] = prefetchingPlugins.compactMap {
        $0.prefetch(with: prefetchableComponent)
      }
    }
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    cancelPrefetchingForItemsAt indexPaths: [IndexPath]
  ) {
    for indexPath in indexPaths {
      prefetchingIndexPathOperations.removeValue(forKey: indexPath)?.forEach {
        $0.cancel()
      }
    }
  }
}

extension UIView {

  fileprivate func isValidSize() -> Bool {
    if frame.height == 0.0 {
      return false
    }

    if frame.width == 0.0 {
      return false
    }

    return true
  }

}

// MARK: - UICollectionViewDataSource

extension CollectionViewAdapter: UICollectionViewDataSource {
  public func numberOfSections(in collectionView: UICollectionView) -> Int {
    list?.sections.count ?? 0
  }

  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    sectionItem(at: section)?.cells.count ?? 0
  }

  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let item = item(at: indexPath) else {
      return UICollectionViewCell()
    }

    guard let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: item.component.reuseIdentifier,
      for: indexPath
    ) as? UICollectionViewComponentCell
    else {
      return UICollectionViewCell()
    }

    cell.onSizeChanged = { [weak self] size in
      self?.componentSizeStorage.setCellSize(
        .init(id: item.id, size: size, component: item.component)
      )
    }
    cell.cancellables = prefetchingIndexPathOperations.removeValue(forKey: indexPath)
    cell.render(component: item.component)

    return cell
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    viewForSupplementaryElementOfKind kind: String,
    at indexPath: IndexPath
  ) -> UICollectionReusableView {
    switch kind {
    case UICollectionView.elementKindSectionHeader:
      guard let section = sectionItem(at: indexPath.section),
            let header = section.header
      else {
        return UICollectionReusableView()
      }

      guard let headerView = collectionView.dequeueReusableSupplementaryView(
        ofKind: kind,
        withReuseIdentifier: header.component.reuseIdentifier,
        for: indexPath
      ) as? UICollectionComponentReusableView
      else {
        return UICollectionReusableView()
      }

      headerView.onSizeChanged = { [weak self] size in
        self?.componentSizeStorage.setHeaderSize(
          .init(id: section.id, size: size, component: header.component)
        )
      }
      headerView.render(component: header.component)

      return headerView

    case UICollectionView.elementKindSectionFooter:
      guard let section = sectionItem(at: indexPath.section),
            let footer = section.footer
      else {
        return UICollectionReusableView()
      }

      guard let footerView = collectionView.dequeueReusableSupplementaryView(
        ofKind: kind,
        withReuseIdentifier: footer.component.reuseIdentifier,
        for: indexPath
      ) as? UICollectionComponentReusableView
      else {
        return UICollectionReusableView()
      }

      footerView.onSizeChanged = { [weak self] size in
        self?.componentSizeStorage.setFooterSize(
          .init(id: section.id, size: size, component: footer.component)
        )
      }
      footerView.render(component: footer.component)

      return footerView
    default:
      return UICollectionReusableView()
    }
  }
}
