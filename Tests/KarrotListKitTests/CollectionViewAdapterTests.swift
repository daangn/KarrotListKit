//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Combine
import UIKit

import XCTest

@testable import KarrotListKit

final class CollectionViewAdapterTests: XCTestCase {

  final class CollectionViewPrefetchingPluginDummy: CollectionViewPrefetchingPlugin {

    func prefetch(with component: ComponentResourcePrefetchable) -> AnyCancellable? {
      nil
    }
  }

  final class CollectionViewMock: UICollectionView {

    override var window: UIWindow? {
      .init()
    }

    var contentSizeHandler: (() -> CGSize)?

    override var contentSize: CGSize {
      get { contentSizeHandler?() ?? super.contentSize }
      set {  }
    }

    var indexPathsForVisibleItemsHandler: (() -> [IndexPath])?
    override var indexPathsForVisibleItems: [IndexPath] {
      indexPathsForVisibleItemsHandler?() ?? []
    }

    var performBatchUpdatesCallCount = 0
    var performBatchUpdatesHandler: ((_ updates: (() -> Void)?, _ completion: ((Bool) -> Void)?) -> Void)?
    override func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
      performBatchUpdatesCallCount += 1
      if let performBatchUpdatesHandler {
        performBatchUpdatesHandler(updates, completion)
      }
    }

    override func reloadData() {}
    override func deleteSections(_ sections: IndexSet) {}
    override func insertSections(_ sections: IndexSet) {}
    override func reloadSections(_ sections: IndexSet) {}
    override func moveSection(_ section: Int, toSection newSection: Int) {}
    override func deleteItems(at indexPaths: [IndexPath]) {}
    override func insertItems(at indexPaths: [IndexPath]) {}
    override func reloadItems(at indexPaths: [IndexPath]) {}
    override func moveItem(at indexPath: IndexPath, to newIndexPath: IndexPath) {}
  }

  final class ViewStub: UIView {

    var sizeThatFitsStub: CGSize!
    override func sizeThatFits(_ size: CGSize) -> CGSize {
      sizeThatFitsStub
    }
  }

  final class CollectionViewPrefetchingPluginMock: CollectionViewPrefetchingPlugin {

    var prefetchHandler: ((ComponentResourcePrefetchable) -> AnyCancellable?)?
    func prefetch(with component: ComponentResourcePrefetchable) -> AnyCancellable? {
      if let prefetchHandler {
        return prefetchHandler(component)
      }

      fatalError("prefetchHandler must be set")
    }
  }

  final class CancellableSpy: Cancellable {

    var cancelCallCount = 0
    func cancel() {
      cancelCallCount += 1
    }
  }

  func sut(
    configuration: CollectionViewAdapterConfiguration = .init(),
    collectionView: UICollectionView,
    layoutAdapter: CollectionViewLayoutAdaptable = CollectionViewLayoutAdapter(),
    prefetchingPlugins: [CollectionViewPrefetchingPlugin] = []
  ) -> CollectionViewAdapter {
    CollectionViewAdapter(
      configuration: configuration,
      collectionView: collectionView,
      layoutAdapter: layoutAdapter,
      prefetchingPlugins: prefetchingPlugins
    )
  }
}

// MARK: - Initializes

extension CollectionViewAdapterTests {

  func test_when_inititalized_then_setup_delegate() {
    // given
    let collectionView = UICollectionView(layoutAdapter: CollectionViewLayoutAdapter())

    // when
    let sut = sut(collectionView: collectionView)

    // then
    XCTAssertTrue(collectionView.delegate === sut)
  }

  func test_when_inititalized_then_setup_dataSource() {
    // given
    let collectionView = UICollectionView(layoutAdapter: CollectionViewLayoutAdapter())

    // when
    let sut = sut(collectionView: collectionView)

    // then
    XCTAssertTrue(collectionView.dataSource === sut)
  }

  func test_when_inititalized_then_setup_layoutAdapterDataSource() {
    // given
    let layoutAdapter = CollectionViewLayoutAdapter()
    let collectionView = UICollectionView(layoutAdapter: layoutAdapter)

    // when
    let sut = sut(
      collectionView: collectionView,
      layoutAdapter: layoutAdapter
    )

    // then
    XCTAssertTrue(layoutAdapter.dataSource === sut)
  }

  func test_given_prefetchingPlugins_when_inititalized_then_setup_prefetchDataSource() {
    // given
    let collectionView = UICollectionView(layoutAdapter: CollectionViewLayoutAdapter())
    let prefetchingPluginDummy = CollectionViewPrefetchingPluginDummy()

    // when
    let sut = sut(
      collectionView: collectionView,
      prefetchingPlugins: [prefetchingPluginDummy]
    )

    // then
    XCTAssertTrue(collectionView.prefetchDataSource === sut)
  }

  func test_given_emptyPrefetchingPlugins_when_inititalized_then_prefetchDataSource_is_nil() {
    // given
    let collectionView = UICollectionView(layoutAdapter: CollectionViewLayoutAdapter())

    // when
    _ = sut(
      collectionView: collectionView,
      prefetchingPlugins: []
    )

    // then
    XCTAssertNil(collectionView.prefetchDataSource)
  }

  func test_given_enabledRefreshControl_when_inititalized_then_setup_refreshControl() {
    let collectionView = UICollectionView(layoutAdapter: CollectionViewLayoutAdapter())
    let configuration = CollectionViewAdapterConfiguration(
      refreshControl: .enabled(tintColor: .clear)
    )

    // when
    _ = sut(
      configuration: configuration,
      collectionView: collectionView
    )

    // then
    XCTAssertNotNil(collectionView.refreshControl)
  }

  func test_given_disabledRefreshControl_when_inititalized_then_refreshControl_is_nil() {
    let collectionView = UICollectionView(layoutAdapter: CollectionViewLayoutAdapter())
    let configuration = CollectionViewAdapterConfiguration(
      refreshControl: .disabled()
    )

    // when
    _ = sut(
      configuration: configuration,
      collectionView: collectionView
    )

    // then
    XCTAssertNil(collectionView.refreshControl)
  }
}

// MARK: - Applying list

extension CollectionViewAdapterTests {

  func test_when_first_apply_then_setup_list() {
    // given
    let collectionView = CollectionViewMock(layoutAdapter: CollectionViewLayoutAdapter())
    let sut = sut(collectionView: collectionView)
    sut.list = nil

    // when
    sut.apply(
      List {
        Section(id: "Section") {
          Cell(
            id: "Cell",
            component: DummyComponent()
          )
        }
      }
    )

    // then
    XCTAssertEqual(
      sut.snapshot()?.sections,
      [
        Section(id: "Section") {
          Cell(
            id: "Cell",
            component: DummyComponent()
          )
        },
      ]
    )
  }

  @MainActor
  func test_given_applied_list_when_apply_then_update() async {
    // given
    let expectation = XCTestExpectation()
    expectation.expectedFulfillmentCount = 1

    let collectionView = CollectionViewMock(layoutAdapter: CollectionViewLayoutAdapter())
    collectionView.performBatchUpdatesHandler = { updates, completion in
      updates?()
      completion?(true)
    }
    let sut = sut(collectionView: collectionView)
    sut.list = List {
      Section(id: UUID()) {
        Cell(id: UUID(), component: DummyComponent())
      }
    }

    // when
    sut.apply(
      List {
        Section(id: "Section") {
          Cell(
            id: "Cell",
            component: DummyComponent()
          )
        }
      },
      completion: {
        expectation.fulfill()
      }
    )

    await fulfillment(of: [expectation], timeout: 1.0)

    // then
    XCTAssertEqual(
      sut.snapshot()?.sections,
      [
        Section(id: "Section") {
          Cell(
            id: "Cell",
            component: DummyComponent()
          )
        },
      ]
    )
  }

  @MainActor
  func test_when_multiple_async_apply_then_safe_update() async {
    // given
    let expectation = XCTestExpectation()
    expectation.expectedFulfillmentCount = 1

    let collectionView = CollectionViewMock(layoutAdapter: CollectionViewLayoutAdapter())
    collectionView.performBatchUpdatesHandler = { updates, completion in
      updates?()
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
        completion?(true)
      }
    }

    let sut = sut(collectionView: collectionView)

    // when
    for i in 0 ... 100 {
      DispatchQueue.main.async {
        sut.apply(
          List {
            Section(id: "Section-\(i)") {
              Cell(
                id: "Cell-\(i)",
                component: DummyComponent()
              )
            }
          },
          completion: {
            // then
            let areEqual = sut.snapshot()!.sections.isContentEqual(
              to: [
                Section(
                  id: "Section-\(i)",
                  cells: [
                    Cell(
                      id: "Cell-\(i)",
                      component: DummyComponent()
                    ),
                  ]
                ),
              ]
            )
            XCTAssertTrue(areEqual)

            if i == 100 {
              expectation.fulfill()
            }
          }
        )
      }
    }

    await fulfillment(of: [expectation], timeout: 2.0)
  }
}

// MARK: - Register reuseIdentifiers

extension CollectionViewAdapterTests {

  func test_when_apply_then_can_return_cell() {
    // given
    let collectionView = CollectionViewMock(layoutAdapter: CollectionViewLayoutAdapter())
    let sut = sut(collectionView: collectionView)
    let view = UIView()
    var component = ComponentStub()
    component.contentStub = view

    // when
    sut.apply(
      List {
        Section(id: UUID()) {
          Cell(id: UUID(), component: component)
        }
      }
    )

    // then
    let cell = collectionView.dataSource?.collectionView(
      collectionView,
      cellForItemAt: IndexPath(item: 0, section: 0)
    ) as! UICollectionViewComponentCell
    XCTAssertIdentical(cell.renderedContent, view)
  }

  func test_when_apply_then_can_return_header() {
    // given
    let collectionView = CollectionViewMock(layoutAdapter: CollectionViewLayoutAdapter())
    let sut = sut(collectionView: collectionView)
    let view = UIView()
    var component = ComponentStub()
    component.contentStub = view

    // when
    sut.apply(
      List {
        Section(id: UUID(), cells: [])
          .withHeader(component)
      }
    )

    // then
    let header = collectionView.dataSource?.collectionView?(
      collectionView,
      viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader,
      at: IndexPath(item: 0, section: 0)
    ) as! UICollectionComponentReusableView
    XCTAssertIdentical(header.renderedContent, view)
  }

  func test_when_apply_then_can_return_footer() {
    // given
    let collectionView = CollectionViewMock(layoutAdapter: CollectionViewLayoutAdapter())
    let sut = sut(collectionView: collectionView)
    let view = UIView()
    var component = ComponentStub()
    component.contentStub = view

    // when
    sut.apply(
      List {
        Section(id: UUID(), cells: [])
          .withFooter(component)
      }
    )

    // then
    let footer = collectionView.dataSource?.collectionView?(
      collectionView,
      viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionFooter,
      at: IndexPath(item: 0, section: 0)
    ) as! UICollectionComponentReusableView
    XCTAssertIdentical(footer.renderedContent, view)
  }
}

// MARK: - UICollectionViewDelegate

extension CollectionViewAdapterTests {

  func test_given_selectionHandler_when_selectCell_then_handleEvent() {
    // given
    var eventContext: DidSelectEvent.EventContext!
    let collectionView = UICollectionView(layoutAdapter: CollectionViewLayoutAdapter())
    let component = DummyComponent()
    let sut = sut(collectionView: collectionView)
    sut.list = List {
      Section(id: UUID()) {
        Cell(id: UUID(), component: component)
          .didSelect { context in
            eventContext = context
          }
      }
    }

    // when
    collectionView
      .delegate?
      .collectionView?(
        collectionView,
        didSelectItemAt: IndexPath(item: 0, section: 0)
      )

    // then
    XCTAssertEqual(eventContext.indexPath, IndexPath(item: 0, section: 0))
  }

  func test_given_willDisplayHandler_when_willDisplayCell_then_handleEvent() {
    // given
    var eventContext: WillDisplayEvent.EventContext!
    let collectionView = UICollectionView(layoutAdapter: CollectionViewLayoutAdapter())
    let component = DummyComponent()
    let sut = sut(collectionView: collectionView)
    sut.list = List {
      Section(id: UUID()) {
        Cell(id: UUID(), component: component)
          .willDisplay { context in
            eventContext = context
          }
      }
    }

    // when
    collectionView
      .delegate?
      .collectionView?(
        collectionView,
        willDisplay: UICollectionViewCell(
          frame: CGRect(origin: .zero, size: .init(width: 44.0, height: 44.0))
        ),
        forItemAt: IndexPath(item: 0, section: 0)
      )

    // then
    XCTAssertEqual(eventContext.indexPath, IndexPath(item: 0, section: 0))
  }

  func test_given_didEndDisplayingHandler_when_didEndDisplayingCell_then_handleEvent() {
    // given
    var eventContext: DidEndDisplayingEvent.EventContext!
    let collectionView = UICollectionView(layoutAdapter: CollectionViewLayoutAdapter())
    let component = DummyComponent()
    let sut = sut(collectionView: collectionView)
    sut.list = List {
      Section(id: UUID()) {
        Cell(id: UUID(), component: component)
          .didEndDisplay { context in
            eventContext = context
          }
      }
    }

    // when
    collectionView
      .delegate?
      .collectionView?(
        collectionView,
        didEndDisplaying: UICollectionViewCell(
          frame: CGRect(origin: .zero, size: .init(width: 44.0, height: 44.0))
        ),
        forItemAt: IndexPath(item: 0, section: 0)
      )

    // then
    XCTAssertEqual(eventContext.indexPath, IndexPath(item: 0, section: 0))
  }

  func test_given_willDisplayHandler_when_willDisplayHeader_then_handleEvent() {
    // given
    var eventContext: WillDisplayEvent.EventContext!
    let collectionView = UICollectionView(layoutAdapter: CollectionViewLayoutAdapter())
    let component = DummyComponent()
    let sut = sut(collectionView: collectionView)
    sut.list = List {
      Section(id: UUID(), cells: [])
        .withHeader(component)
        .willDisplayHeader { context in
          eventContext = context
        }
    }

    // when
    collectionView
      .delegate?
      .collectionView?(
        collectionView,
        willDisplaySupplementaryView: UICollectionReusableView(
          frame: CGRect(origin: .zero, size: CGSize(width: 44.0, height: 44.0))
        ),
        forElementKind: UICollectionView.elementKindSectionHeader,
        at: IndexPath(item: 0, section: 0)
      )

    // then
    XCTAssertEqual(eventContext.indexPath, IndexPath(item: 0, section: 0))
  }

  func test_given_willDisplayHandler_when_willDisplayFooter_then_handleEvent() {
    // given
    var eventContext: WillDisplayEvent.EventContext!
    let collectionView = UICollectionView(layoutAdapter: CollectionViewLayoutAdapter())
    let component = DummyComponent()
    let sut = sut(collectionView: collectionView)
    sut.list = List {
      Section(id: UUID(), cells: [])
        .withFooter(component)
        .willDisplayFooter { context in
          eventContext = context
        }
    }

    // when
    collectionView
      .delegate?
      .collectionView?(
        collectionView,
        willDisplaySupplementaryView: UICollectionReusableView(
          frame: CGRect(origin: .zero, size: CGSize(width: 44.0, height: 44.0))
        ),
        forElementKind: UICollectionView.elementKindSectionFooter,
        at: IndexPath(item: 0, section: 0)
      )

    // then
    XCTAssertEqual(eventContext.indexPath, IndexPath(item: 0, section: 0))
  }

  func test_given_didEndDisplayHandler_when_didEndDisplayingHeader_then_handleEvent() {
    // given
    var eventContext: DidEndDisplayingEvent.EventContext!
    let collectionView = UICollectionView(layoutAdapter: CollectionViewLayoutAdapter())
    let component = DummyComponent()
    let sut = sut(collectionView: collectionView)
    sut.list = List {
      Section(id: UUID(), cells: [])
        .withHeader(component)
        .didEndDisplayHeader { context in
          eventContext = context
        }
    }

    // when
    collectionView
      .delegate?
      .collectionView?(
        collectionView,
        didEndDisplayingSupplementaryView: UICollectionReusableView(
          frame: CGRect(origin: .zero, size: CGSize(width: 44.0, height: 44.0))
        ),
        forElementOfKind: UICollectionView.elementKindSectionHeader,
        at: IndexPath(item: 0, section: 0)
      )

    // then
    XCTAssertEqual(eventContext.indexPath, IndexPath(item: 0, section: 0))
  }

  func test_given_didEndDisplayHandler_when_didEndDisplayingFooter_then_handleEvent() {
    // given
    var eventContext: DidEndDisplayingEvent.EventContext!
    let collectionView = UICollectionView(layoutAdapter: CollectionViewLayoutAdapter())
    let component = DummyComponent()
    let sut = sut(collectionView: collectionView)
    sut.list = List {
      Section(id: UUID(), cells: [])
        .withFooter(component)
        .didEndDisplayFooter { context in
          eventContext = context
        }
    }

    // when
    collectionView
      .delegate?
      .collectionView?(
        collectionView,
        didEndDisplayingSupplementaryView: UICollectionReusableView(
          frame: CGRect(origin: .zero, size: CGSize(width: 44.0, height: 44.0))
        ),
        forElementOfKind: UICollectionView.elementKindSectionFooter,
        at: IndexPath(item: 0, section: 0)
      )

    // then
    XCTAssertEqual(eventContext.indexPath, IndexPath(item: 0, section: 0))
  }
}

// MARK: - UIScrollViewDelegate

extension CollectionViewAdapterTests {

  func test_given_didScrollHandler_when_didScroll_then_handleEvent() {
    // given
    var eventContext: DidScrollEvent.EventContext!
    let collectionView = UICollectionView(layoutAdapter: CollectionViewLayoutAdapter())
    let sut = sut(collectionView: collectionView)
    sut.list = List(
      sections: []
    ).didScroll { context in
      eventContext = context
    }

    // when
    collectionView
      .delegate?
      .scrollViewDidScroll?(
        collectionView
      )

    // then
    XCTAssertIdentical(eventContext.collectionView, collectionView)
  }

  func test_given_willBeginDraggingHandler_when_willBeginDragging_then_handleEvent() {
    // given
    var eventContext: WillBeginDraggingEvent.EventContext!
    let collectionView = UICollectionView(layoutAdapter: CollectionViewLayoutAdapter())
    let sut = sut(collectionView: collectionView)
    sut.list = List(
      sections: []
    ).willBeginDragging { context in
      eventContext = context
    }

    // when
    collectionView
      .delegate?
      .scrollViewWillBeginDragging?(
        collectionView
      )

    // then
    XCTAssertIdentical(eventContext.collectionView, collectionView)
  }

  func test_given_willEndDraggingHandler_when_willEndDragging_then_handleEvent() {
    // given
    var eventContext: WillEndDraggingEvent.EventContext!
    let collectionView = UICollectionView(layoutAdapter: CollectionViewLayoutAdapter())
    let sut = sut(collectionView: collectionView)
    sut.list = List(
      sections: []
    ).willEndDragging { context in
      eventContext = context
    }

    // when
    let velocity = CGPoint(x: 0, y: 100)
    var targetContentOffset = CGPoint(x: 0, y: 1000)
    collectionView
      .delegate?
      .scrollViewWillEndDragging?(
        collectionView,
        withVelocity: velocity,
        targetContentOffset: withUnsafeMutablePointer(to: &targetContentOffset) { $0 }
      )

    // then
    XCTAssertIdentical(eventContext.collectionView, collectionView)
    XCTAssertEqual(eventContext.velocity, velocity)
    XCTAssertEqual(eventContext.targetContentOffset.pointee, targetContentOffset)
  }

  func test_given_didEndDraggingHandler_when_didEndDragging_then_handleEvent() {
    // given
    var eventContext: DidEndDraggingEvent.EventContext!
    let collectionView = UICollectionView(layoutAdapter: CollectionViewLayoutAdapter())
    let sut = sut(collectionView: collectionView)
    sut.list = List(
      sections: []
    ).didEndDragging { context in
      eventContext = context
    }

    // when
    let decelerate = true
    collectionView
      .delegate?
      .scrollViewDidEndDragging?(
        collectionView,
        willDecelerate: decelerate
      )

    // then
    XCTAssertIdentical(eventContext.collectionView, collectionView)
    XCTAssertEqual(eventContext.decelerate, decelerate)
  }

  func test_given_didScrollToTopHandler_when_didScrollToTop_then_handleEvent() {
    // given
    var eventContext: DidScrollToTopEvent.EventContext!
    let collectionView = UICollectionView(layoutAdapter: CollectionViewLayoutAdapter())
    let sut = sut(collectionView: collectionView)
    sut.list = List(
      sections: []
    ).didScrollToTop { context in
      eventContext = context
    }

    // when
    collectionView
      .delegate?
      .scrollViewDidScrollToTop?(
        collectionView
      )

    // then
    XCTAssertIdentical(eventContext.collectionView, collectionView)
  }

  func test_given_willBeginDeceleratingHandler_when_willBeginDecelerating_then_handleEvent() {
    // given
    var eventContext: WillBeginDeceleratingEvent.EventContext!
    let collectionView = UICollectionView(layoutAdapter: CollectionViewLayoutAdapter())
    let sut = sut(collectionView: collectionView)
    sut.list = List(
      sections: []
    ).willBeginDecelerating { context in
      eventContext = context
    }

    // when
    collectionView
      .delegate?
      .scrollViewWillBeginDecelerating?(
        collectionView
      )

    // then
    XCTAssertIdentical(eventContext.collectionView, collectionView)
  }

  func test_given_didEndDeceleratingHandler_when_didEndDecelerating_then_handleEvent() {
    // given
    var eventContext: DidEndDeceleratingEvent.EventContext!
    let collectionView = UICollectionView(layoutAdapter: CollectionViewLayoutAdapter())
    let sut = sut(collectionView: collectionView)
    sut.list = List(
      sections: []
    ).didEndDecelerating { context in
      eventContext = context
    }

    // when
    collectionView
      .delegate?
      .scrollViewDidEndDecelerating?(
        collectionView
      )

    // then
    XCTAssertIdentical(eventContext.collectionView, collectionView)
  }

  func test_given_refreshControlEnabled_and_handler_when_pullToRefresh_then_handleEvent() {
    // given
    var eventContext: PullToRefreshEvent.EventContext!
    let collectionView = UICollectionView(layoutAdapter: CollectionViewLayoutAdapter())
    let sut = sut(
      configuration: .init(refreshControl: .enabled(tintColor: .clear)),
      collectionView: collectionView
    )
    sut.list = List(
      sections: []
    ).onRefresh { context in
      eventContext = context
    }

    // when
    collectionView
      .refreshControl?
      .allTargets.forEach { target in
        collectionView
          .refreshControl?
          .actions(forTarget: target, forControlEvent: .valueChanged)?
          .forEach {
            (target.base as! NSObject).perform(
              NSSelectorFromString($0),
              with: collectionView.refreshControl
            )
          }
      }

    // then
    XCTAssertNotNil(eventContext)
  }
}

// MARK: - UICollectionViewDataSourcePrefetching

extension CollectionViewAdapterTests {

  func test_given_prefetchable_when_prefetch_then_added() {
    // given: prefetchingPlugin and prefetchable component
    let cancellable = AnyCancellable {}
    let collectionView = CollectionViewMock(layoutAdapter: CollectionViewLayoutAdapter())
    let prefetchingPlugin = CollectionViewPrefetchingPluginMock()
    prefetchingPlugin.prefetchHandler = { _ in
      cancellable
    }
    let sut = sut(
      collectionView: collectionView,
      prefetchingPlugins: [prefetchingPlugin]
    )
    // given: applied list
    sut.apply(
      List {
        Section(id: UUID()) {
          Cell(
            id: UUID(), component: DummyComponent()
          )
        }
      }
    )

    // when
    collectionView
      .prefetchDataSource?
      .collectionView(
        collectionView,
        prefetchItemsAt: [IndexPath(item: 0, section: 0)]
      )

    // then
    XCTAssertEqual(sut.prefetchingIndexPathOperations.count, 1)
    XCTAssertIdentical(
      sut.prefetchingIndexPathOperations[IndexPath(item: 0, section: 0)]!.first!,
      cancellable
    )
  }

  func test_given_prefetchingOperation_when_cancelPrefetching_then_removed() {
    // given: mocking prefetchingPlugin
    let cancellable = CancellableSpy()
    let collectionView = CollectionViewMock(layoutAdapter: CollectionViewLayoutAdapter())
    let prefetchingPlugin = CollectionViewPrefetchingPluginMock()
    prefetchingPlugin.prefetchHandler = { _ in
      AnyCancellable(cancellable)
    }
    let sut = sut(
      collectionView: collectionView,
      prefetchingPlugins: [prefetchingPlugin]
    )
    // given: applied list
    sut.apply(
      List {
        Section(id: UUID()) {
          Cell(
            id: UUID(), component: DummyComponent()
          )
        }
      }
    )

    // given: creating prefetchingOperation
    collectionView
      .prefetchDataSource?
      .collectionView(
        collectionView,
        prefetchItemsAt: [IndexPath(item: 0, section: 0)]
      )

    // when
    collectionView
      .prefetchDataSource?
      .collectionView?(
        collectionView,
        cancelPrefetchingForItemsAt: [IndexPath(item: 0, section: 0)]
      )

    // then
    XCTAssertTrue(sut.prefetchingIndexPathOperations.isEmpty)
    XCTAssertEqual(cancellable.cancelCallCount, 1)
  }

  func test_given_prefetchingOperation_when_setUpCell_then_pass_operation() {
    // given: mocking prefetchingPlugin
    let cancellable = AnyCancellable {}
    let prefetchingPlugin = CollectionViewPrefetchingPluginMock()
    prefetchingPlugin.prefetchHandler = { _ in
      cancellable
    }
    let collectionView = CollectionViewMock(layoutAdapter: CollectionViewLayoutAdapter())
    let sut = sut(
      collectionView: collectionView,
      prefetchingPlugins: [prefetchingPlugin]
    )
    // given: applied list
    sut.apply(List {
      Section(id: UUID()) {
        Cell(
          id: UUID(), component: DummyComponent()
        )
      }
    })

    // given: creating prefetchingOperation
    collectionView
      .prefetchDataSource?
      .collectionView(
        collectionView,
        prefetchItemsAt: [IndexPath(item: 0, section: 0)]
      )

    // when
    let cell = collectionView
      .dataSource?
      .collectionView(
        collectionView,
        cellForItemAt: IndexPath(item: 0, section: 0)
      ) as! UICollectionViewComponentCell

    // then
    XCTAssertTrue(sut.prefetchingIndexPathOperations.isEmpty)
    XCTAssertEqual(cell.cancellables!.count, 1)
    XCTAssertIdentical(cell.cancellables!.first!, cancellable)
  }
}

// MARK: - UICollectionViewDataSource

extension CollectionViewAdapterTests {

  func test_given_applied_list_when_numberOfItems_then_item_count_in_section() {
    // given
    let cellCount = 100
    let collectionView = CollectionViewMock(layoutAdapter: CollectionViewLayoutAdapter())
    let sut = sut(collectionView: collectionView)
    sut.list = List {
      Section(id: UUID()) {
        (0 ..< cellCount).map {
          Cell(id: "\($0)", component: DummyComponent())
        }
      }
    }

    // when
    let numberOfItems = collectionView
      .dataSource?
      .collectionView(
        collectionView,
        numberOfItemsInSection: 0
      )

    // then
    XCTAssertEqual(numberOfItems, cellCount)
  }

  func test_given_applied_list_when_numberOfSections_then_section_count() {
    // given
    let sectionCount = 100
    let collectionView = CollectionViewMock(layoutAdapter: CollectionViewLayoutAdapter())
    let sut = sut(collectionView: collectionView)
    sut.list = List {
      (0 ..< 100).map {
        Section(id: "\($0)", cells: [])
      }
    }

    // when
    let numberOfSections = collectionView
      .dataSource?
      .numberOfSections?(in: collectionView)

    // then
    XCTAssertEqual(numberOfSections, sectionCount)
  }

  func test_given_applied_list_when_dequeue_cell_then_render() {
    // given
    let collectionView = CollectionViewMock(layoutAdapter: CollectionViewLayoutAdapter())
    let component = ComponentSpy()
    let sut = sut(collectionView: collectionView)
    sut.apply(
      List {
        Section(id: UUID()) {
          [Cell(id: UUID(), component: component)]
        }
      }
    )

    // when
    _ = collectionView
      .dataSource?
      .collectionView(
        collectionView,
        cellForItemAt: IndexPath(item: 0, section: 0)
      )

    // then
    XCTAssertEqual(component.renderCallCount, 1)
  }

  func test_given_applied_list_when_dequeue_header_then_render() {
    // given
    let collectionView = CollectionViewMock(layoutAdapter: CollectionViewLayoutAdapter())
    let component = ComponentSpy()
    let sut = sut(collectionView: collectionView)
    sut.apply(
      List {
        Section(id: UUID(), cells: [])
          .withHeader(component)
      }
    )

    // when
    _ = collectionView
      .dataSource?
      .collectionView?(
        collectionView,
        viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader,
        at: IndexPath(item: 0, section: 0)
      )

    // then
    XCTAssertEqual(component.renderCallCount, 1)
  }

  func test_given_applied_list_when_dequeue_footer_then_render() {
    // given
    let collectionView = CollectionViewMock(layoutAdapter: CollectionViewLayoutAdapter())
    let component = ComponentSpy()
    let sut = sut(collectionView: collectionView)
    sut.apply(
      List {
        Section(id: UUID(), cells: [])
          .withFooter(component)
      }
    )

    // when
    _ = collectionView
      .dataSource?
      .collectionView?(
        collectionView,
        viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionFooter,
        at: IndexPath(item: 0, section: 0)
      )

    // then
    XCTAssertEqual(component.renderCallCount, 1)
  }
}

// MARK: - SizeStorage

extension CollectionViewAdapterTests {

  func test_given_dequeued_cell_when_calculate_size_then_store_size() {
    // given
    let cellID = UUID()
    let collectionView = CollectionViewMock(layoutAdapter: CollectionViewLayoutAdapter())
    var component = ComponentStub()
    component.viewModelStub = .init()
    let viewStub = ViewStub()
    viewStub.sizeThatFitsStub = CGSize(width: 44.0, height: 44.0)
    component.contentStub = viewStub
    let sut = sut(collectionView: collectionView)
    sut.apply(
      List {
        Section(id: UUID()) {
          Cell(id: cellID, component: component)
        }
      }
    )

    let cell = collectionView
      .dataSource?
      .collectionView(
        collectionView,
        cellForItemAt: IndexPath(item: 0, section: 0)
      ) as! UICollectionViewComponentCell

    // when
    _ = cell.preferredLayoutAttributesFitting(
      UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: 0, section: 0))
    )

    // then
    XCTAssertEqual(
      sut.sizeStorage().cellSize(for: cellID)?.size,
      CGSize(width: 44.0, height: 44.0)
    )
  }

  func test_given_dequeued_header_when_calculate_size_then_store_size() {
    // given
    let sectionID = UUID()
    let collectionView = CollectionViewMock(layoutAdapter: CollectionViewLayoutAdapter())
    var component = ComponentStub()
    component.viewModelStub = .init()
    let viewStub = ViewStub()
    viewStub.sizeThatFitsStub = CGSize(width: 44.0, height: 44.0)
    component.contentStub = viewStub
    let sut = sut(collectionView: collectionView)
    sut.apply(
      List {
        Section(id: sectionID, cells: [])
          .withHeader(component)
      }
    )

    let header = collectionView
      .dataSource?
      .collectionView?(
        collectionView,
        viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader,
        at: IndexPath(item: 0, section: 0)
      ) as! UICollectionComponentReusableView

    // when
    _ = header.preferredLayoutAttributesFitting(
      UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: 0, section: 0))
    )

    // then
    XCTAssertEqual(
      sut.sizeStorage().headerSize(for: sectionID)?.size,
      CGSize(width: 44.0, height: 44.0)
    )
  }

  func test_given_dequeued_footer_when_calculate_size_then_store_size() {
    // given
    let sectionID = UUID()
    let collectionView = CollectionViewMock(layoutAdapter: CollectionViewLayoutAdapter())
    var component = ComponentStub()
    component.viewModelStub = .init()
    let viewStub = ViewStub()
    viewStub.sizeThatFitsStub = CGSize(width: 44.0, height: 44.0)
    component.contentStub = viewStub
    let sut = sut(collectionView: collectionView)
    sut.apply(
      List {
        Section(id: sectionID, cells: [])
          .withFooter(component)
      }
    )
    let header = collectionView
      .dataSource?
      .collectionView?(
        collectionView,
        viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionFooter,
        at: IndexPath(item: 0, section: 0)
      ) as! UICollectionComponentReusableView

    // when
    _ = header.preferredLayoutAttributesFitting(
      UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: 0, section: 0))
    )

    // then
    XCTAssertEqual(
      sut.sizeStorage().footerSize(for: sectionID)?.size,
      CGSize(width: 44.0, height: 44.0)
    )
  }
}

// MARK: - Next batch update

extension CollectionViewAdapterTests {

  func test_given_not_triggerable_offset_when_willDisplayItem_then_not_triggered() {
    // given
    let collectionView = CollectionViewMock(layoutAdapter: CollectionViewLayoutAdapter())
    collectionView.frame = CGRect(x: 0, y: 0, width: 1.0, height: 100.0)
    collectionView.contentSizeHandler = { CGSize(width: 1.0, height: 400.0) }

    let sut = sut(
      configuration: .init(
        leadingScreensForNextBatching: 2.0
      ),
      collectionView: collectionView
    )
    var nextBatchContext: NextBatchContext!

    var point = CGPoint(x: 0.0, y: 0.0)
    let targetContentOffset = withUnsafeMutablePointer(to: &point) { $0 }

    sut.apply(
      List(sections: [])
        .onNextBatchTrigger(
          decisionProvider: .default {
            return true
          },
          handler: { eventContext in
            nextBatchContext = eventContext.context
          }
        )
    )

    // when
    collectionView.delegate?.scrollViewWillEndDragging?(
      collectionView,
      withVelocity: .zero,
      targetContentOffset: targetContentOffset
    )

    // then
    XCTAssertNil(nextBatchContext)
  }

  func test_given_not_triggerable_offset_when_willDisplayItem_then_not_triggered2() {
    // given
    let collectionView = CollectionViewMock(layoutAdapter: CollectionViewLayoutAdapter())
    collectionView.frame = CGRect(x: 0, y: 0, width: 1.0, height: 100.0)
    collectionView.contentSizeHandler = { CGSize(width: 1.0, height: 400.0) }

    let sut = sut(
      configuration: .init(
        leadingScreensForNextBatching: 2.0
      ),
      collectionView: collectionView
    )
    var nextBatchContext: NextBatchContext!

    var point = CGPoint(x: 0.0, y: 99.0)
    let targetContentOffset = withUnsafeMutablePointer(to: &point) { $0 }

    sut.apply(
      List(sections: [])
        .onNextBatchTrigger(
          decisionProvider: .default {
            return true
          },
          handler: { eventContext in
            nextBatchContext = eventContext.context
          }
        )
    )

    // when
    collectionView.delegate?.scrollViewWillEndDragging?(
      collectionView,
      withVelocity: .zero,
      targetContentOffset: targetContentOffset
    )

    // then
    XCTAssertNil(nextBatchContext)
  }

  func test_given_triggerable_offset_when_willDisplayItem_then_triggered() {
    // given
    let collectionView = CollectionViewMock(layoutAdapter: CollectionViewLayoutAdapter())
    collectionView.frame = CGRect(x: 0, y: 0, width: 1.0, height: 100.0)
    collectionView.contentSizeHandler = { CGSize(width: 1.0, height: 400.0) }

    let sut = sut(
      configuration: .init(
        leadingScreensForNextBatching: 2.0
      ),
      collectionView: collectionView
    )
    var nextBatchContext: NextBatchContext!

    var point = CGPoint(x: 0.0, y: 100.0)
    let targetContentOffset = withUnsafeMutablePointer(to: &point) { $0 }

    sut.apply(
      List(sections: [])
        .onNextBatchTrigger(
          decisionProvider: .default {
            return true
          },
          handler: { eventContext in
            nextBatchContext = eventContext.context
          }
        )
    )

    // when
    collectionView.delegate?.scrollViewWillEndDragging?(
      collectionView,
      withVelocity: .zero,
      targetContentOffset: targetContentOffset
    )

    // then
    XCTAssertNotNil(nextBatchContext)
  }

  func test_given_condition_returns_false_when_willDisplayItem_then_not_triggered() {
    // given
    let collectionView = CollectionViewMock(layoutAdapter: CollectionViewLayoutAdapter())
    collectionView.frame = CGRect(x: 0, y: 0, width: 1.0, height: 100.0)
    collectionView.contentSizeHandler = { CGSize(width: 1.0, height: 400.0) }

    let sut = sut(
      configuration: .init(
        leadingScreensForNextBatching: 2.0
      ),
      collectionView: collectionView
    )
    var nextBatchContext: NextBatchContext!

    var point = CGPoint(x: 0.0, y: 100.0)
    let targetContentOffset = withUnsafeMutablePointer(to: &point) { $0 }

    sut.apply(
      List(sections: [])
        .onNextBatchTrigger(
          decisionProvider: .default {
            return false
          },
          handler: { eventContext in
            nextBatchContext = eventContext.context
          }
        )
    )

    // when
    collectionView.delegate?.scrollViewWillEndDragging?(
      collectionView,
      withVelocity: .zero,
      targetContentOffset: targetContentOffset
    )

    // then
    XCTAssertNil(nextBatchContext)
  }

  func test_given_context_is_fetching_when_willDisplayItem_then_not_triggered() {
    // given
    let collectionView = CollectionViewMock(layoutAdapter: CollectionViewLayoutAdapter())
    collectionView.frame = CGRect(x: 0, y: 0, width: 1.0, height: 100.0)
    collectionView.contentSizeHandler = { CGSize(width: 1.0, height: 400.0) }

    let sut = sut(
      configuration: .init(
        leadingScreensForNextBatching: 2.0
      ),
      collectionView: collectionView
    )

    var handlerCallCount = 0

    var point = CGPoint(x: 0.0, y: 100.0)
    let targetContentOffset = withUnsafeMutablePointer(to: &point) { $0 }

    sut.apply(
      List(sections: [])
        .onNextBatchTrigger(
          decisionProvider: .default {
            return true
          },
          handler: { _ in
            handlerCallCount += 1
          }
        )
    )

    collectionView.delegate?.scrollViewWillEndDragging?(
      collectionView,
      withVelocity: .zero,
      targetContentOffset: targetContentOffset
    )

    // when
    collectionView.delegate?.scrollViewWillEndDragging?(
      collectionView,
      withVelocity: .zero,
      targetContentOffset: targetContentOffset
    )

    // then
    XCTAssertEqual(handlerCallCount, 1)
  }
}
