//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Combine
import UIKit

import DifferenceKit

open class CollectionView: UICollectionView {

  /// The configuration for the CollectionViewAdapter.
  public var configuration: CollectionViewAdapterConfiguration

  /// The set of cell reuseIdentifiers that have been registered on the collection view.
  private var registeredCellReuseIdentifiers = Set<String>()

  /// The set of header reuseIdentifiers that have been registered on the collection view.
  private var registeredHeaderReuseIdentifiers = Set<String>()

  /// The set of footer reuseIdentifiers that have been registered on the collection view.
  private var registeredFooterReuseIdentifiers = Set<String>()

  private(set) var prefetchingIndexPathOperations = [IndexPath: [AnyCancellable]]()
  private let prefetchingPlugins: [CollectionViewPrefetchingPlugin]

  private var isUpdating = false
  private var queuedUpdate: (
    list: List,
    updateStrategy: CollectionViewAdapterUpdateStrategy,
    completion: (() -> Void)?
  )?

  var list: List?

  private lazy var pullToRefreshControl: UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    refreshControl.tintColor = configuration.refreshControl.tintColor
    refreshControl.addTarget(
      self,
      action: #selector(pullToRefresh),
      for: .valueChanged
    )
    return refreshControl
  }()

  public init(
    layout: UICollectionViewLayout,
    configuration: CollectionViewAdapterConfiguration,
    prefetchingPlugins: [CollectionViewPrefetchingPlugin] = []
  ) {
    self.configuration = configuration
    self.prefetchingPlugins = prefetchingPlugins

    super.init(frame: .zero, collectionViewLayout: layout)

    delegate = self
    dataSource = self

    if prefetchingPlugins.isEmpty == false {
      prefetchDataSource = self
    }

    if configuration.refreshControl.isEnabled {
      refreshControl = pullToRefreshControl
    }
  }

  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func apply(
    _ list: List,
    updateStrategy: CollectionViewAdapterUpdateStrategy = .animatedBatchUpdates,
    completion: (() -> Void)? = nil
  ) {
    guard isUpdating == false else {
      queuedUpdate = (list, updateStrategy, completion)
      return
    }

    isUpdating = true

    let overridedCompletion: (Bool) -> Void = { [weak self] _ in
      guard let self else {
        return
      }

      completion?()

      if let nextUpdate = queuedUpdate, window != nil {
        queuedUpdate = nil
        isUpdating = false
        apply(
          nextUpdate.list,
          updateStrategy: nextUpdate.updateStrategy,
          completion: nextUpdate.completion
        )
      } else {
        isUpdating = false
      }
    }

    registerReuseIdentifiers(with: list.sections)

    if self.list == nil || self.list?.sections.count == 0 {
      self.list = list
      reloadData()
      layoutIfNeeded()
      overridedCompletion(true)
      return
    }

    switch updateStrategy {
    case .animatedBatchUpdates:
      performDifferentialUpdates(
        old: self.list, new: list, completion: { flag in
          overridedCompletion(flag)
        }
      )
    case .nonanimatedBatchUpdates:
      UIView.performWithoutAnimation {
        performDifferentialUpdates(
          old: self.list, new: list, completion: { flag in
            overridedCompletion(flag)
          }
        )
      }
    case .reloadData:
      self.list = list
      reloadData()
      layoutIfNeeded()
      overridedCompletion(true)
    }
  }

  @_disfavoredOverload
  @available(*, deprecated, renamed: "apply(_:updateStrategy:completion:)", message: "")
  public func apply(
    _ list: List,
    animatingDifferences: Bool = true,
    completion: (() -> Void)? = nil
  ) {
    apply(
      list,
      updateStrategy: animatingDifferences ? .animatedBatchUpdates : .nonanimatedBatchUpdates,
      completion: completion
    )
  }

  /// Representation of the current state of the data in the collection view.
  public func snapshot() -> List? {
    list
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

    reload(
      using: changeset,
      interrupt: { $0.changeCount > self.configuration.batchUpdateInterruptCount },
      setData: { sections in
        list?.sections = sections
      },
      completion: completion
    )
  }

  /// Registers reuse identifiers for cells, headers, and footers in a UICollectionView.
  ///
  /// It dynamically registers the cells, headers, and footers at runtime.
  /// This allows for greater flexibility and reduces the need for boilerplate code.
  ///
  /// - Parameter sections: An array of `Section` objects. Each `Section` object contains information about a cell, header, and footer.
  private func registerReuseIdentifiers(with sections: [Section]) {
    sections.forEach { section in
      if let headerReuseIdentifier = section.header?.component.reuseIdentifier,
         !registeredHeaderReuseIdentifiers.contains(headerReuseIdentifier) {
        registeredHeaderReuseIdentifiers.insert(headerReuseIdentifier)
        register(
          UICollectionComponentReusableView.self,
          forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
          withReuseIdentifier: headerReuseIdentifier
        )
      }

      if let footerReuseIdentifier = section.footer?.component.reuseIdentifier,
         !registeredFooterReuseIdentifiers.contains(footerReuseIdentifier) {
        registeredFooterReuseIdentifiers.insert(footerReuseIdentifier)
        register(
          UICollectionComponentReusableView.self,
          forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
          withReuseIdentifier: footerReuseIdentifier
        )
      }

      let cellReuseIdentifiers = Set(section.cells.map { $0.component.reuseIdentifier })
      cellReuseIdentifiers.subtracting(registeredCellReuseIdentifiers).forEach { cellReuseIdentifier in
        registeredCellReuseIdentifiers.insert(cellReuseIdentifier)
        register(
          UICollectionViewComponentCell.self,
          forCellWithReuseIdentifier: cellReuseIdentifier
        )
      }
    }
  }

  public func sectionItem(at index: Int) -> Section? {
    list?.sections[safe: index]
  }

  public func item(at indexPath: IndexPath) -> Cell? {
    sectionItem(at: indexPath.section)?.cells[safe: indexPath.item]
  }

  @objc
  private func pullToRefresh() {
    list?.event(for: PullToRefreshEvent.self)?.handler(.init())
  }
}


extension CollectionView: UICollectionViewDataSource {

  public func numberOfSections(in collectionView: UICollectionView) -> Int {
    list?.sections.count ?? 0
  }

  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    sectionItem(at: section)?.cells.count ?? 0
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    guard let item = item(at: indexPath) else {
      return UICollectionViewCell()
    }

    guard let cell = dequeueReusableCell(
      withReuseIdentifier: item.component.reuseIdentifier,
      for: indexPath
    ) as? UICollectionViewComponentCell
    else {
      return UICollectionViewCell()
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

      guard let headerView = dequeueReusableSupplementaryView(
        ofKind: kind,
        withReuseIdentifier: header.component.reuseIdentifier,
        for: indexPath
      ) as? UICollectionComponentReusableView
      else {
        return UICollectionReusableView()
      }

      headerView.render(component: header.component)

      return headerView

    case UICollectionView.elementKindSectionFooter:
      guard let section = sectionItem(at: indexPath.section),
            let footer = section.footer
      else {
        return UICollectionReusableView()
      }

      guard let footerView = dequeueReusableSupplementaryView(
        ofKind: kind,
        withReuseIdentifier: footer.component.reuseIdentifier,
        for: indexPath
      ) as? UICollectionComponentReusableView
      else {
        return UICollectionReusableView()
      }

      footerView.render(component: footer.component)

      return footerView
    default:
      return UICollectionReusableView()
    }
  }
}


extension CollectionView: UICollectionViewDelegate {

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
    guard let item = item(at: indexPath) else {
      return
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
    guard let item = item(at: indexPath) else {
      return
    }

    item.event(for: DidEndDisplayingEvent.self)?.handler(
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

  public func collectionView(
    _ collectionView: UICollectionView,
    didHighlightItemAt indexPath: IndexPath
  ) {
    guard let item = item(at: indexPath) else {
      return
    }

    item.event(for: HighlightEvent.self)?.handler(
      .init(
        indexPath: indexPath,
        anyComponent: item.component,
        content: (cellForItem(at: indexPath) as? ComponentRenderable)?.renderedContent
      )
    )
  }

  public func collectionView(
    _ collectionView: UICollectionView,
    didUnhighlightItemAt indexPath: IndexPath
  ) {
    guard let item = item(at: indexPath) else {
      return
    }

    item.event(for: UnhighlightEvent.self)?.handler(
      .init(
        indexPath: indexPath,
        anyComponent: item.component,
        content: (cellForItem(at: indexPath) as? ComponentRenderable)?.renderedContent
      )
    )
  }
}


extension CollectionView: UICollectionViewDataSourcePrefetching {

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
