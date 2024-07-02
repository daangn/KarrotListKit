//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Combine
import UIKit

import DifferenceKit

/// An adapter for `UICollectionView`
///
/// The `CollectionViewAdapter` object serves as an adapter between the `UIColletionView` logic and the `KarrotListKit` logic
/// encapsulating the core implementation logic of the framework
///
/// Internally, it uses the collectionView delegate and dataSource. If you want to implement callback methods,
/// you can receive callbacks through modifiers.
/// Please note, you should never set the delegate and dataSource of the collectionView directly.
final public class CollectionViewAdapter: NSObject {

  /// The configuration for the CollectionViewAdapter.
  public var configuration: CollectionViewAdapterConfiguration

  /// The set of cell reuseIdentifiers that have been registered on the collection view.
  private var registeredCellReuseIdentifiers = Set<String>()

  /// The set of header reuseIdentifiers that have been registered on the collection view.
  private var registeredHeaderReuseIdentifiers = Set<String>()

  /// The set of footer reuseIdentifiers that have been registered on the collection view.
  private var registeredFooterReuseIdentifiers = Set<String>()

  private weak var collectionView: UICollectionView?

  private(set) var prefetchingIndexPathOperations = [IndexPath: [AnyCancellable]]()
  private let prefetchingPlugins: [CollectionViewPrefetchingPlugin]

  private var isUpdating = false
  private var queuedUpdate: (
    list: List,
    animatingDifferences: Bool,
    completion: (() -> Void)?
  )?

  private var componentSizeStorage: ComponentSizeStorage = ComponentSizeStorageImpl()

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

  // MARK: - Initializer

  /// Initialize a new instance of `UICollectionViewAdapter`.
  ///
  /// - Parameters:
  ///   - configuration: The configuration for adapter.
  ///   - collectionView: The `UICollectionView` that be displayed on the screen.
  ///   - layoutAdapter: Adapting between collectionView-layout and data-model.
  ///   - prefetchingPlugins: The plugins for prefetching resource
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

  /// Updates the UI to reflect the state of the data in the list, optionally animating the UI changes and executing a completion handler.
  ///
  /// - Parameters:
  ///   - list: The list that reflects the new state of the data in the collection view.
  ///   - animatingDifferences: If true, the framework animates the updates to the collection view. If false, the framework doesn’t animate the updates to the collection view.
  ///   - completion: A closure to execute when the updates are complete. This closure has no return value and takes no parameters. The framework calls this closure from the main queue.
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
      overridedCompletion(true)
      return
    }

    if animatingDifferences {
      performDifferentialUpdates(
        old: self.list, new: list, completion: { flag in
          overridedCompletion(flag)
        }
      )
    } else {
      UIView.performWithoutAnimation {
        performDifferentialUpdates(
          old: self.list, new: list, completion: { flag in
            overridedCompletion(flag)
          }
        )
      }
    }
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

    collectionView?.reload(
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

  // MARK: - Action Methods

  @objc
  private func pullToRefresh() {
    list?.event(for: PullToRefreshEvent.self)?.handler(.init())
  }
}


// MARK: - Next Batch Trigger

extension CollectionViewAdapter {

  private var scrollDirection: UICollectionView.ScrollDirection {
    let layout = collectionView?.collectionViewLayout as? UICollectionViewCompositionalLayout
    return layout?.configuration.scrollDirection ?? .vertical
  }

  /// Checks if the collection view has reached the bottom, and triggers the `ReachedBottomEvent` if needed.
  ///
  /// This method manually evaluates if the collection view is near the bottom, based on the current content offset and view bounds.\
  /// Should call this method on `scrollViewDidScroll(_:)` function of `UIScrollViewDelegate`.\
  /// Basically, the `ReachedBottomEvent` check is handled in the `scrollViewWillEndDragging` method.
  private func manuallyCheckReachedBottomEventIfNeeded() {
    guard
      let collectionView,
      collectionView.isDragging == false,
      collectionView.isTracking == false
    else {
      return
    }
    triggerReachedBottomEventIfNeeded(contentOffset: collectionView.contentOffset)
  }

  /// Evaluates the position of the content offset and triggers the `ReachedBottomEvent` if the end of the content is near.
  ///
  /// - Parameter contentOffset: The current offset of the content view.
  ///
  /// This method calculates the distance to the bottom of the content, considering the current scroll direction (vertical or horizontal).\
  /// It computes the view length, content length, and offset based on the scroll direction. If the content length is smaller than the view length,\
  /// it immediately triggers the `ReachedBottomEvent`. Otherwise, it calculates the remaining distance and compares it to the trigger distance.\
  /// If the remaining distance is less than or equal to the trigger distance, the `ReachedBottomEvent` is triggered.\
  private func triggerReachedBottomEventIfNeeded(contentOffset: CGPoint) {
    guard
      let event = list?.event(for: ReachedBottomEvent.self),
      let collectionView, collectionView.bounds.isEmpty == false
    else {
      return
    }

    let viewLength: CGFloat
    let contentLength: CGFloat
    let offset: CGFloat

    switch scrollDirection {
    case .vertical:
      viewLength = collectionView.bounds.size.height
      contentLength = collectionView.contentSize.height
      offset = contentOffset.y

    default:
      viewLength = collectionView.bounds.size.width
      contentLength = collectionView.contentSize.width
      offset = contentOffset.x
    }

    if contentLength < viewLength {
      event.handler(.init())
      return
    }

    let triggerDistance: CGFloat = {
      switch event.offset {
      case .absolute(let offset):
        return offset
      case .multipleHeight(let multipleHeight):
        return viewLength * multipleHeight
      }
    }()

    let remainingDistance = contentLength - viewLength - offset
    if remainingDistance <= triggerDistance {
      event.handler(.init())
    }
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

    manuallyCheckReachedBottomEventIfNeeded()
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

    triggerReachedBottomEventIfNeeded(contentOffset: targetContentOffset.pointee)
  }

  public func scrollViewDidEndDragging(
    _ scrollView: UIScrollView,
    willDecelerate decelerate: Bool
  ) {
    guard let collectionView else {
      return
    }

    list?.event(for: DidEndDraggingEvent.self)?.handler(
      .init(
        collectionView: collectionView,
        decelerate: decelerate
      )
    )
  }

  public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
    guard let collectionView else {
      return
    }

    list?.event(for: DidScrollToTopEvent.self)?.handler(
      .init(
        collectionView: collectionView
      )
    )
  }

  public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
    guard let collectionView else {
      return
    }

    list?.event(for: WillBeginDeceleratingEvent.self)?.handler(
      .init(
        collectionView: collectionView
      )
    )
  }

  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    guard let collectionView else {
      return
    }

    list?.event(for: DidEndDeceleratingEvent.self)?.handler(
      .init(
        collectionView: collectionView
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

// MARK: - UICollectionViewDataSource

extension CollectionViewAdapter: UICollectionViewDataSource {
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

    guard let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: item.component.reuseIdentifier,
      for: indexPath
    ) as? UICollectionViewComponentCell
    else {
      return UICollectionViewCell()
    }

    cell.onSizeChanged = { [weak self] size in
      self?.componentSizeStorage.setCellSize(
        (size, item.component.viewModel),
        for: item.id
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
          (size, header.component.viewModel),
          for: section.id
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
          (size, footer.component.viewModel),
          for: section.id
        )
      }
      footerView.render(component: footer.component)

      return footerView
    default:
      return UICollectionReusableView()
    }
  }
}
