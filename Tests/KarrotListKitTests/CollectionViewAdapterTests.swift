//
//  CollectionViewAdapterTests.swift
//
//
//  Created by Jaxtyn on 3/14/24.
//
//

import UIKit
import Combine

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

    var performBatchUpdatesCallCount: Int = 0
    var performBatchUpdatesHandler: ((_ updates: (() -> Void)?, _ completion: ((Bool) -> Void)?) -> Void)?
    override func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
      performBatchUpdatesCallCount += 1
      if let performBatchUpdatesHandler {
        performBatchUpdatesHandler(updates, completion)
      }
    }

    override func reloadData() { }
    override func deleteSections(_ sections: IndexSet) { }
    override func insertSections(_ sections: IndexSet) { }
    override func reloadSections(_ sections: IndexSet) { }
    override func moveSection(_ section: Int, toSection newSection: Int) { }
    override func deleteItems(at indexPaths: [IndexPath]) { }
    override func insertItems(at indexPaths: [IndexPath]) { }
    override func reloadItems(at indexPaths: [IndexPath]) { }
    override func moveItem(at indexPath: IndexPath, to newIndexPath: IndexPath) { }
  }

  final class DummyView: UIView {

  }

  struct DummyComponent: Component {

    struct ViewModel: Equatable { }

    typealias Content = UIView
    typealias Coordinator = Void

    var layoutMode: ContentLayoutMode {
      .flexibleHeight(estimatedHeight: 44.0)
    }

    var viewModel: ViewModel = .init()

    func renderContent(coordinator: Coordinator) -> UIView {
      UIView()
    }

    func render(in content: UIView, coordinator: Coordinator) {
      // nothing
    }
  }

  struct ComponentStub: Component {

    struct ViewModel: Equatable { }

    typealias Content = UIView
    typealias Coordinator = Void

    var viewModel: ViewModel {
      viewModelStub
    }

    var layoutMode: ContentLayoutMode {
      layoutModeStub
    }

    var layoutModeStub: ContentLayoutMode!
    var viewModelStub: ViewModel!
    var contentStub: UIView!

    func renderContent(coordinator: Coordinator) -> UIView {
      contentStub
    }

    func render(in content: UIView, coordinator: Coordinator) {
      // nothing
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
        }
      ]
    )
  }

  @MainActor
  func test_given_applied_list_when_apply_then_update() async {
    // given
    let expectation = XCTestExpectation().then {
      $0.expectedFulfillmentCount = 1
    }
    let collectionView = CollectionViewMock(layoutAdapter: CollectionViewLayoutAdapter()).then {
      $0.performBatchUpdatesHandler = { updates, completion in
        updates?()
        completion?(true)
      }
    }
    let sut = sut(collectionView: collectionView).then {
      $0.list = List {
        Section(id: UUID()) {
          Cell(id: UUID(), component: DummyComponent())
        }
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
        }
      ]
    )
  }

  @MainActor
  func test_when_multiple_async_apply_then_safe_update() async {
    // given
    let expectation = XCTestExpectation().then {
      $0.expectedFulfillmentCount = 1
    }
    let collectionView = CollectionViewMock(layoutAdapter: CollectionViewLayoutAdapter()).then {
      $0.performBatchUpdatesHandler = { updates, completion in
        updates?()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
          completion?(true)
        }
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
                    )
                  ]
                )
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
    let view = DummyView()
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
    XCTAssertIdentical(
      cell.renderedContent,
      view
    )
  }

  func test_when_apply_then_can_return_header() {
    // given
    let collectionView = CollectionViewMock(layoutAdapter: CollectionViewLayoutAdapter())
    let sut = sut(collectionView: collectionView)
    let view = DummyView()
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
    XCTAssertIdentical(
      header.renderedContent,
      view
    )
  }

  func test_when_apply_then_can_return_footer() {
    // given
    let collectionView = CollectionViewMock(layoutAdapter: CollectionViewLayoutAdapter())
    let sut = sut(collectionView: collectionView)
    let view = DummyView()
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
    XCTAssertIdentical(
      footer.renderedContent,
      view
    )
  }
}

// MARK: - UICollectionViewDelegate

extension CollectionViewAdapterTests {

  func test_given_selectionHandler_when_selectCell_then_handleEvent() {
    // given
    var eventContext: DidSelectEvent.EventContext!
    let collectionView = UICollectionView(layoutAdapter: CollectionViewLayoutAdapter())
    let component = DummyComponent()
    let sut = sut(collectionView: collectionView).then {
      $0.list = List {
        Section(id: UUID()) {
          Cell(id: UUID(), component: component)
            .didSelect { context in
              eventContext = context
            }
        }
      }
    }
    _ = sut

    // when
    collectionView
      .delegate?
      .collectionView?(
        collectionView,
        didSelectItemAt: IndexPath(item: 0, section: 0)
      )

    // then
    XCTAssertEqual(
      eventContext.indexPath,
      IndexPath(item: 0, section: 0)
    )
  }

  func test_given_willDisplayHandler_when_willDisplayCell_then_handleEvent() {
    // given
    var eventContext: WillDisplayEvent.EventContext!
    let collectionView = UICollectionView(layoutAdapter: CollectionViewLayoutAdapter())
    let component = DummyComponent()
    let sut = sut(collectionView: collectionView).then {
      $0.list = List {
        Section(id: UUID()) {
          Cell(id: UUID(), component: component)
            .willDisplay { context in
              eventContext = context
            }
        }
      }
    }
    _ = sut

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
    XCTAssertEqual(
      eventContext.indexPath,
      IndexPath(item: 0, section: 0)
    )
  }

  func test_given_didEndDisplayingHandler_when_didEndDisplayingCell_then_handleEvent() {
    // given
    var eventContext: DidEndDisplayingEvent.EventContext!
    let collectionView = UICollectionView(layoutAdapter: CollectionViewLayoutAdapter())
    let component = DummyComponent()
    let sut = sut(collectionView: collectionView).then {
      $0.list = List {
        Section(id: UUID()) {
          Cell(id: UUID(), component: component)
            .didEndDisplay { context in
              eventContext = context
            }
        }
      }
    }
    _ = sut

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
    XCTAssertEqual(
      eventContext.indexPath,
      IndexPath(item: 0, section: 0)
    )
  }

  func test_given_willDisplayHandler_when_willDisplayHeader_then_handleEvent() {
    // given
    var eventContext: WillDisplayEvent.EventContext!
    let collectionView = UICollectionView(layoutAdapter: CollectionViewLayoutAdapter())
    let component = DummyComponent()
    let sut = sut(collectionView: collectionView).then {
      $0.list = List {
        Section(id: UUID(), cells: [])
          .withHeader(component)
          .willDisplayHeader { context in
            eventContext = context
          }
      }
    }
    _ = sut

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
    XCTAssertEqual(
      eventContext.indexPath,
      IndexPath(item: 0, section: 0)
    )
  }

  func test_given_willDisplayHandler_when_willDisplayFooter_then_handleEvent() {
    // given
    var eventContext: WillDisplayEvent.EventContext!
    let collectionView = UICollectionView(layoutAdapter: CollectionViewLayoutAdapter())
    let component = DummyComponent()
    let sut = sut(collectionView: collectionView).then {
      $0.list = List {
        Section(id: UUID(), cells: [])
          .withFooter(component)
          .willDisplayFooter { context in
            eventContext = context
          }
      }
    }
    _ = sut

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
    XCTAssertEqual(
      eventContext.indexPath,
      IndexPath(item: 0, section: 0)
    )
  }

  func test_given_didEndDisplayHandler_when_didEndDisplayingHeader_then_handleEvent() {
    // given
    var eventContext: DidEndDisplayingEvent.EventContext!
    let collectionView = UICollectionView(layoutAdapter: CollectionViewLayoutAdapter())
    let component = DummyComponent()
    let sut = sut(collectionView: collectionView).then {
      $0.list = List {
        Section(id: UUID(), cells: [])
          .withHeader(component)
          .didEndDisplayHeader { context in
            eventContext = context
          }
      }
    }
    _ = sut

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
    XCTAssertEqual(
      eventContext.indexPath,
      IndexPath(item: 0, section: 0)
    )
  }

  func test_given_didEndDisplayHandler_when_didEndDisplayingFooter_then_handleEvent() {
    // given
    var eventContext: DidEndDisplayingEvent.EventContext!
    let collectionView = UICollectionView(layoutAdapter: CollectionViewLayoutAdapter())
    let component = DummyComponent()
    let sut = sut(collectionView: collectionView).then {
      $0.list = List {
        Section(id: UUID(), cells: [])
          .withFooter(component)
          .didEndDisplayFooter { context in
            eventContext = context
          }
      }
    }
    _ = sut

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
    XCTAssertEqual(
      eventContext.indexPath,
      IndexPath(item: 0, section: 0)
    )
  }
}

// MARK: - UIScrollViewDelegate

extension CollectionViewAdapterTests {

  func test_given_didScrollHandler_when_didScroll_then_handleEvent() {
    // given
    var eventContext: DidScrollEvent.EventContext!
    let collectionView = UICollectionView(layoutAdapter: CollectionViewLayoutAdapter())
    let sut = sut(collectionView: collectionView).then {
      $0.list = List(
        sections: []
      ).didScroll { context in
        eventContext = context
      }
    }
    _ = sut

    // when
    collectionView
      .delegate?
      .scrollViewDidScroll?(
        collectionView
      )

    // then
    XCTAssertIdentical(
      eventContext.collectionView,
      collectionView
    )
  }

  func test_given_willBeginDraggingHandler_when_willBeginDragging_then_handleEvent() {
    // given
    var eventContext: WillBeginDraggingEvent.EventContext!
    let collectionView = UICollectionView(layoutAdapter: CollectionViewLayoutAdapter())
    let sut = sut(collectionView: collectionView).then {
      $0.list = List(
        sections: []
      ).willBeginDragging { context in
        eventContext = context
      }
    }
    _ = sut

    // when
    collectionView
      .delegate?
      .scrollViewWillBeginDragging?(
        collectionView
      )

    // then
    XCTAssertIdentical(
      eventContext.collectionView,
      collectionView
    )
  }

  func test_given_willEndDraggingHandler_when_willEndDragging_then_handleEvent() {
    // given
    var eventContext: WillEndDraggingEvent.EventContext!
    let collectionView = UICollectionView(layoutAdapter: CollectionViewLayoutAdapter())
    let sut = sut(collectionView: collectionView).then {
      $0.list = List(
        sections: []
      ).willEndDragging { context in
        eventContext = context
      }
    }
    _ = sut

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
    XCTAssertIdentical(
      eventContext.collectionView,
      collectionView
    )
    XCTAssertEqual(
      eventContext.velocity,
      velocity
    )
    XCTAssertEqual(
      eventContext.targetContentOffset.pointee,
      targetContentOffset
    )
  }

  func test_given_refreshControlEnabled_and_handler_when_pullToRefresh_then_handleEvent() {
    // given
    var eventContext: PullToRefreshEvent.EventContext!
    let collectionView = UICollectionView(layoutAdapter: CollectionViewLayoutAdapter())
    let sut = sut(
      configuration: .init(refreshControl: .enabled(tintColor: .clear)),
      collectionView: collectionView
    ).then {
      $0.list = List(
        sections: []
      ).onRefresh { context in
        eventContext = context
      }
    }
    _ = sut

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
