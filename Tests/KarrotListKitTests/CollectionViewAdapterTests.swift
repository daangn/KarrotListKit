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

    private var windowView = UIWindow()
    override var window: UIWindow? {
      windowView
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
    prefetchingPlugins: [CollectionViewPrefetchingPlugin] = []
  ) -> CollectionViewAdapter<CompositionalLayout> {
    let adapter = CollectionViewAdapter<CompositionalLayout>(
      configuration: configuration,
      prefetchingPlugins: prefetchingPlugins
    )
    return adapter
  }
}

// MARK: - Initializes

extension CollectionViewAdapterTests {

  func test_when_register_then_setup_delegate() {
    // given
    let sut = sut()
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )

    // when
    sut.register(collectionView: collectionView)

    // then
    XCTAssertTrue(collectionView.delegate === sut)
  }

  func test_when_register_then_setup_dataSource() {
    // given
    let sut = sut()
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )

    // when
    sut.register(collectionView: collectionView)

    // then
    XCTAssertTrue(collectionView.dataSource === sut)
  }

  func test_given_prefetchingPlugins_when_register_then_setup_prefetchDataSource() {
    // given
    let sut = sut(prefetchingPlugins: [CollectionViewPrefetchingPluginDummy()])
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )

    // when
    sut.register(collectionView: collectionView)

    // then
    XCTAssertTrue(collectionView.prefetchDataSource === sut)
  }

  func test_given_emptyPrefetchingPlugins_when_register_then_prefetchDataSource_is_nil() {
    // given
    let sut = sut(prefetchingPlugins: [])
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )

    // when
    sut.register(collectionView: collectionView)

    // then
    XCTAssertNil(collectionView.prefetchDataSource)
  }

  func test_given_enabledRefreshControl_when_register_then_setup_refreshControl() {
    // given
    let configuration = CollectionViewAdapterConfiguration(
      refreshControl: .enabled(tintColor: .clear)
    )
    let sut = sut(configuration: configuration)
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )

    // when
    sut.register(collectionView: collectionView)

    // then
    XCTAssertNotNil(collectionView.refreshControl)
  }

  func test_given_disabledRefreshControl_when_register_then_refreshControl_is_nil() {
    // given
    let configuration = CollectionViewAdapterConfiguration(
      refreshControl: .disabled()
    )
    let sut = sut(configuration: configuration)
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )

    // when
    sut.register(collectionView: collectionView)

    // then
    XCTAssertNil(collectionView.refreshControl)
  }
}

// MARK: - Applying list

extension CollectionViewAdapterTests {

  func test_when_first_apply_then_setup_list() {
    // given
    let sut = sut()
    let collectionView = CollectionViewMock(
      frame: .zero,
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )
    sut.register(collectionView: collectionView)

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

    let sut = sut()
    let collectionView = CollectionViewMock(
      frame: .zero,
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )
    sut.register(collectionView: collectionView)
    collectionView.performBatchUpdatesHandler = { updates, completion in
      updates?()
      completion?(true)
    }
    sut.apply(
      List {
        Section(id: UUID()) {
          Cell(id: UUID(), component: DummyComponent())
        }
      }
    )

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

    let sut = sut()
    let collectionView = CollectionViewMock(
      frame: .zero,
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )
    sut.register(collectionView: collectionView)
    collectionView.performBatchUpdatesHandler = { updates, completion in
      updates?()
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
        completion?(true)
      }
    }


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
    let sut = sut()
    let collectionView = CollectionViewMock(
      frame: .zero,
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )
    sut.register(collectionView: collectionView)

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
    let sut = sut()
    let collectionView = CollectionViewMock(
      frame: .zero,
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )
    sut.register(collectionView: collectionView)

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
    let sut = sut()
    let collectionView = CollectionViewMock(
      frame: .zero,
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )
    sut.register(collectionView: collectionView)

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
    let sut = sut()
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )
    sut.register(collectionView: collectionView)

    var eventContext: DidSelectEvent.EventContext!
    let component = DummyComponent()

    sut.apply(
      List {
        Section(id: UUID()) {
          Cell(id: UUID(), component: component)
            .didSelect { context in
              eventContext = context
            }
        }
      }
    )

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
    let sut = sut()
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )
    sut.register(collectionView: collectionView)
    
    var eventContext: WillDisplayEvent.EventContext!
    let component = DummyComponent()
    sut.apply(
      List {
        Section(id: UUID()) {
          Cell(id: UUID(), component: component)
            .willDisplay { context in
              eventContext = context
            }
        }
      }
    )

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
    let sut = sut()
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )
    sut.register(collectionView: collectionView)
    
    var eventContext: DidEndDisplayingEvent.EventContext!
    let component = DummyComponent()
    sut.apply(
      List {
        Section(id: UUID()) {
          Cell(id: UUID(), component: component)
            .didEndDisplay { context in
              eventContext = context
            }
        }
      }
    )

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
    let sut = sut()
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )
    sut.register(collectionView: collectionView)
    
    var eventContext: WillDisplayEvent.EventContext!
    let component = DummyComponent()
    sut.apply(
      List {
        Section(id: UUID(), cells: [])
          .withHeader(component)
          .willDisplayHeader { context in
            eventContext = context
          }
      }
    )

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
    let sut = sut()
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )
    sut.register(collectionView: collectionView)
    
    var eventContext: WillDisplayEvent.EventContext!
    let component = DummyComponent()
    sut.apply(
      List {
        Section(id: UUID(), cells: [])
          .withFooter(component)
          .willDisplayFooter { context in
            eventContext = context
          }
      }
    )

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
    let sut = sut()
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )
    sut.register(collectionView: collectionView)
    
    var eventContext: DidEndDisplayingEvent.EventContext!
    let component = DummyComponent()
    sut.apply(
      List {
        Section(id: UUID(), cells: [])
          .withHeader(component)
          .didEndDisplayHeader { context in
            eventContext = context
          }
      }
    )

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
    let sut = sut()
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )
    sut.register(collectionView: collectionView)
    
    var eventContext: DidEndDisplayingEvent.EventContext!
    let component = DummyComponent()
    sut.apply(
      List {
        Section(id: UUID(), cells: [])
          .withFooter(component)
          .didEndDisplayFooter { context in
            eventContext = context
          }
      }
    )

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

  func test_given_highlightHandler_when_highlightCell_then_handleEvent() {
    // given
    let sut = sut()
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )
    sut.register(collectionView: collectionView)
    
    var eventContext: HighlightEvent.EventContext!
    let component = DummyComponent()
    sut.apply(
      List {
        Section(id: UUID()) {
          Cell(id: UUID(), component: component)
            .onHighlight { context in
              eventContext = context
            }
        }
      }
    )

    // when
    collectionView
      .delegate?
      .collectionView?(
        collectionView,
        didHighlightItemAt: IndexPath(item: 0, section: 0)
      )

    // then
    XCTAssertEqual(eventContext.indexPath, IndexPath(item: 0, section: 0))
  }

  func test_given_unhighlightHandler_when_unhighlightCell_then_handleEvent() {
    // given
    let sut = sut()
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )
    sut.register(collectionView: collectionView)
    
    var eventContext: UnhighlightEvent.EventContext!
    let component = DummyComponent()
    sut.apply(
      List {
        Section(id: UUID()) {
          Cell(id: UUID(), component: component)
            .onUnhighlight { context in
              eventContext = context
            }
        }
      }
    )

    // when
    collectionView
      .delegate?
      .collectionView?(
        collectionView,
        didUnhighlightItemAt: IndexPath(item: 0, section: 0)
      )

    // then
    XCTAssertEqual(eventContext.indexPath, IndexPath(item: 0, section: 0))
  }
}

// MARK: - UIScrollViewDelegate

extension CollectionViewAdapterTests {

  func test_given_didScrollHandler_when_didScroll_then_handleEvent() {
    // given
    let sut = sut()
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )
    sut.register(collectionView: collectionView)
    
    var eventContext: DidScrollEvent.EventContext!
    sut.apply(
      List(
        sections: []
      ).didScroll { context in
        eventContext = context
      }
    )

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
    let sut = sut()
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )
    sut.register(collectionView: collectionView)
    
    var eventContext: WillBeginDraggingEvent.EventContext!
    sut.apply(
      List(
        sections: []
      ).willBeginDragging { context in
        eventContext = context
      }
    )

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
    let sut = sut()
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )
    sut.register(collectionView: collectionView)
    
    var eventContext: WillEndDraggingEvent.EventContext!
    sut.apply(
      List(
        sections: []
      ).willEndDragging { context in
        eventContext = context
      }
    )

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
    let sut = sut()
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )
    sut.register(collectionView: collectionView)
    
    var eventContext: DidEndDraggingEvent.EventContext!
    sut.apply(
      List(
        sections: []
      ).didEndDragging { context in
        eventContext = context
      }
    )

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
    let sut = sut()
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )
    sut.register(collectionView: collectionView)
    
    var eventContext: DidScrollToTopEvent.EventContext!
    sut.apply(
      List(
        sections: []
      ).didScrollToTop { context in
        eventContext = context
      }
    )

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
    let sut = sut()
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )
    sut.register(collectionView: collectionView)
    
    var eventContext: WillBeginDeceleratingEvent.EventContext!
    sut.apply(
      List(
        sections: []
      ).willBeginDecelerating { context in
        eventContext = context
      }
    )

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
    let sut = sut()
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )
    sut.register(collectionView: collectionView)
    
    var eventContext: DidEndDeceleratingEvent.EventContext!
    sut.apply(
      List(
        sections: []
      ).didEndDecelerating { context in
        eventContext = context
      }
    )

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
    let sut = sut(
      configuration: .init(refreshControl: .enabled(tintColor: .clear))
    )
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )
    sut.register(collectionView: collectionView)
    
    var eventContext: PullToRefreshEvent.EventContext!
    sut.apply(
      List(
        sections: []
      ).onRefresh { context in
        eventContext = context
      }
    )

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

  func test_given_scrollToTopValue_when_try_scrollToTop_then_handleShouldScrollToTopEvent() {
    [true, false].forEach { value in
      // given
      let sut = sut(
        configuration: .init()
      )
      let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
      )
      sut.register(collectionView: collectionView)
      
      var eventContext: ShouldScrollToTopEvent.EventContext!
      sut.apply(
        List(
          sections: []
        ).shouldScrollToTop { context in
          eventContext = context
          return value
        }
      )

      // when
      let shouldScrollToTop = collectionView
        .delegate?.scrollViewShouldScrollToTop?(collectionView)

      // then
      XCTAssertEqual(shouldScrollToTop, value)
      XCTAssertNotNil(eventContext)
    }
  }
}

// MARK: - UICollectionViewDataSourcePrefetching

extension CollectionViewAdapterTests {

  func test_given_prefetchable_when_prefetch_then_added() {
    // given: prefetchingPlugin and prefetchable component
    let prefetchingPlugin = CollectionViewPrefetchingPluginMock()
    let cancellable = AnyCancellable {}
    prefetchingPlugin.prefetchHandler = { _ in
      cancellable
    }
    let sut = sut(
      prefetchingPlugins: [prefetchingPlugin]
    )
    let collectionView = CollectionViewMock(
      frame: .zero,
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )
    sut.register(collectionView: collectionView)
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
    let prefetchingPlugin = CollectionViewPrefetchingPluginMock()
    let cancellable = CancellableSpy()
    prefetchingPlugin.prefetchHandler = { _ in
      AnyCancellable(cancellable)
    }
    let sut = sut(
      prefetchingPlugins: [prefetchingPlugin]
    )
    let collectionView = CollectionViewMock(
      frame: .zero,
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )
    sut.register(collectionView: collectionView)
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
    let prefetchingPlugin = CollectionViewPrefetchingPluginMock()
    let cancellable = AnyCancellable {}
    prefetchingPlugin.prefetchHandler = { _ in
      cancellable
    }
    let sut = sut(
      prefetchingPlugins: [prefetchingPlugin]
    )
    let collectionView = CollectionViewMock(
      frame: .zero,
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )
    sut.register(collectionView: collectionView)
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
    let sut = sut()
    let collectionView = CollectionViewMock(
      frame: .zero,
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )
    sut.register(collectionView: collectionView)
    
    let cellCount = 100
    sut.apply(
      List {
        Section(id: UUID()) {
          (0 ..< cellCount).map {
            Cell(id: "\($0)", component: DummyComponent())
          }
        }
      }
    )

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
    let sut = sut()
    let collectionView = CollectionViewMock(
      frame: .zero,
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )
    sut.register(collectionView: collectionView)
    
    let sectionCount = 100
    sut.apply(
      List {
        (0 ..< 100).map {
          Section(id: "\($0)", cells: [])
        }
      }
    )

    // when
    let numberOfSections = collectionView
      .dataSource?
      .numberOfSections?(in: collectionView)

    // then
    XCTAssertEqual(numberOfSections, sectionCount)
  }

  func test_given_applied_list_when_dequeue_cell_then_render() {
    // given
    let sut = sut()
    let collectionView = CollectionViewMock(
      frame: .zero,
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )
    sut.register(collectionView: collectionView)
    
    let component = ComponentSpy()
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
    let sut = sut()
    let collectionView = CollectionViewMock(
      frame: .zero,
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )
    sut.register(collectionView: collectionView)
    
    let component = ComponentSpy()
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
    let sut = sut()
    let collectionView = CollectionViewMock(
      frame: .zero,
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )
    sut.register(collectionView: collectionView)
    
    let component = ComponentSpy()
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

// MARK: - Reached End Event Trigger

extension CollectionViewAdapterTests {

  func test_given_not_triggerable_offset_when_scrollViewWillEndDragging_then_not_triggered() {
    // given
    let sut = sut()
    let collectionView = CollectionViewMock(
      frame: CGRect(x: 0, y: 0, width: 1.0, height: 100.0),
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )
    sut.register(collectionView: collectionView)

    collectionView.contentSizeHandler = { CGSize(width: 1.0, height: 400.0) }

    var handlerCallCount = 0

    sut.apply(
      List(sections: [])
        .onReachEnd(offsetFromEnd: .absolute(100.0)) { _ in
          handlerCallCount += 1
        }
    )

    var point = CGPoint(x: 0.0, y: 0.0)
    let targetContentOffset = withUnsafeMutablePointer(to: &point) { $0 }

    // when
    collectionView.delegate?.scrollViewWillEndDragging?(
      collectionView,
      withVelocity: .zero,
      targetContentOffset: targetContentOffset
    )

    // then
    XCTAssertEqual(handlerCallCount, 0)
  }

  func test_given_not_triggerable_offset_when_scrollViewWillEndDragging_then_not_triggered_2() {
    // given
    let sut = sut()
    let collectionView = CollectionViewMock(
      frame: CGRect(x: 0, y: 0, width: 1.0, height: 100.0),
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )
    collectionView.contentSizeHandler = { CGSize(width: 1.0, height: 400.0) }

    var handlerCallCount = 0

    sut.register(collectionView: collectionView)
    sut.apply(
      List(sections: [])
        .onReachEnd(offsetFromEnd: .absolute(100.0)) { _ in
          handlerCallCount += 1
        }
    )

    var point = CGPoint(x: 0.0, y: 199.0)
    let targetContentOffset = withUnsafeMutablePointer(to: &point) { $0 }

    // when
    collectionView.delegate?.scrollViewWillEndDragging?(
      collectionView,
      withVelocity: .zero,
      targetContentOffset: targetContentOffset
    )

    // then
    XCTAssertEqual(handlerCallCount, 0)
  }

  func test_given_not_triggerable_offset_when_scrollViewWillEndDragging_then_not_triggered_3() {
    // given
    let sut = sut()
    let collectionView = CollectionViewMock(
      frame: CGRect(x: 0, y: 0, width: 1.0, height: 100.0),
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )
    collectionView.contentSizeHandler = { CGSize(width: 1.0, height: 400.0) }

    var handlerCallCount = 0

    sut.register(collectionView: collectionView)
    sut.apply(
      List(sections: [])
        .onReachEnd(offsetFromEnd: .relativeToContainerSize(multiplier: 1.0)) { _ in
          handlerCallCount += 1
        }
    )

    var point = CGPoint(x: 0.0, y: 199.0)
    let targetContentOffset = withUnsafeMutablePointer(to: &point) { $0 }

    // when
    collectionView.delegate?.scrollViewWillEndDragging?(
      collectionView,
      withVelocity: .zero,
      targetContentOffset: targetContentOffset
    )

    // then
    XCTAssertEqual(handlerCallCount, 0)
  }

  func test_given_not_triggerable_offset_when_scrollViewWillEndDragging_then_not_triggered_4() {
    // given
    let sut = sut()
    let collectionView = CollectionViewMock(
      frame: CGRect(x: 0, y: 0, width: 1.0, height: 100.0),
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )
    sut.register(collectionView: collectionView)

    collectionView.contentSizeHandler = { CGSize(width: 1.0, height: 400.0) }

    var handlerCallCount = 0

    sut.apply(
      List(sections: [])
        .onReachEnd(offsetFromEnd: .relativeToContainerSize(multiplier: 2.0)) { _ in
          handlerCallCount += 1
        }
    )

    var point = CGPoint(x: 0.0, y: 99.0)
    let targetContentOffset = withUnsafeMutablePointer(to: &point) { $0 }

    // when
    collectionView.delegate?.scrollViewWillEndDragging?(
      collectionView,
      withVelocity: .zero,
      targetContentOffset: targetContentOffset
    )

    // then
    XCTAssertEqual(handlerCallCount, 0)
  }

  func test_given_triggerable_offset_when_scrollViewWillEndDragging_then_triggered() {
    // given
    let sut = sut()
    let collectionView = CollectionViewMock(
      frame: CGRect(x: 0, y: 0, width: 1.0, height: 100.0),
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )
    sut.register(collectionView: collectionView)

    collectionView.contentSizeHandler = { CGSize(width: 1.0, height: 400.0) }

    var handlerCallCount = 0

    sut.apply(
      List(sections: [])
        .onReachEnd(offsetFromEnd: .absolute(100.0)) { _ in
          handlerCallCount += 1
        }
    )

    var point = CGPoint(x: 0.0, y: 200.0)
    let targetContentOffset = withUnsafeMutablePointer(to: &point) { $0 }

    // when
    collectionView.delegate?.scrollViewWillEndDragging?(
      collectionView,
      withVelocity: .zero,
      targetContentOffset: targetContentOffset
    )

    // then
    XCTAssertEqual(handlerCallCount, 1)
  }

  func test_given_triggerable_offset_when_scrollViewWillEndDragging_then_triggered_2() {
    // given
    let sut = sut()
    let collectionView = CollectionViewMock(
      frame: CGRect(x: 0, y: 0, width: 1.0, height: 100.0),
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )
    sut.register(collectionView: collectionView)

    collectionView.contentSizeHandler = { CGSize(width: 1.0, height: 400.0) }

    var handlerCallCount = 0

    sut.apply(
      List(sections: [])
        .onReachEnd(offsetFromEnd: .absolute(100.0)) { _ in
          handlerCallCount += 1
        }
    )

    var point = CGPoint(x: 0.0, y: 201.0)
    let targetContentOffset = withUnsafeMutablePointer(to: &point) { $0 }

    // when
    collectionView.delegate?.scrollViewWillEndDragging?(
      collectionView,
      withVelocity: .zero,
      targetContentOffset: targetContentOffset
    )

    // then
    XCTAssertEqual(handlerCallCount, 1)
  }

  func test_given_triggerable_offset_when_scrollViewWillEndDragging_then_triggered_3() {
    // given
    let sut = sut()
    let collectionView = CollectionViewMock(
      frame: CGRect(x: 0, y: 0, width: 1.0, height: 100.0),
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )
    sut.register(collectionView: collectionView)

    collectionView.contentSizeHandler = { CGSize(width: 1.0, height: 400.0) }

    var handlerCallCount = 0

    sut.apply(
      List(sections: [])
        .onReachEnd(offsetFromEnd: .relativeToContainerSize(multiplier: 1.0)) { _ in
          handlerCallCount += 1
        }
    )

    var point = CGPoint(x: 0.0, y: 200.0)
    let targetContentOffset = withUnsafeMutablePointer(to: &point) { $0 }

    // when
    collectionView.delegate?.scrollViewWillEndDragging?(
      collectionView,
      withVelocity: .zero,
      targetContentOffset: targetContentOffset
    )

    // then
    XCTAssertEqual(handlerCallCount, 1)
  }

  func test_given_triggerable_offset_when_scrollViewWillEndDragging_then_triggered_4() {
    // given
    let sut = sut()
    let collectionView = CollectionViewMock(
      frame: CGRect(x: 0, y: 0, width: 1.0, height: 100.0),
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )
    sut.register(collectionView: collectionView)

    collectionView.contentSizeHandler = { CGSize(width: 1.0, height: 400.0) }

    var handlerCallCount = 0

    sut.apply(
      List(sections: [])
        .onReachEnd(offsetFromEnd: .relativeToContainerSize(multiplier: 2.0)) { _ in
          handlerCallCount += 1
        }
    )

    var point = CGPoint(x: 0.0, y: 100.0)
    let targetContentOffset = withUnsafeMutablePointer(to: &point) { $0 }

    // when
    collectionView.delegate?.scrollViewWillEndDragging?(
      collectionView,
      withVelocity: .zero,
      targetContentOffset: targetContentOffset
    )

    // then
    XCTAssertEqual(handlerCallCount, 1)
  }

  func test_given_triggerable_offset_when_scrollViewWillEndDragging_then_triggered_5() {
    // given
    let sut = sut()
    let collectionView = CollectionViewMock(
      frame: CGRect(x: 0, y: 0, width: 1.0, height: 100.0),
      collectionViewLayout: UICollectionViewCompositionalLayout(
        sectionProvider: sut.sectionLayout
      )
    )
    sut.register(collectionView: collectionView)

    collectionView.contentSizeHandler = { CGSize(width: 1.0, height: 99.0) }

    var handlerCallCount = 0

    sut.apply(
      List(sections: [])
        .onReachEnd(offsetFromEnd: .relativeToContainerSize(multiplier: 2.0)) { _ in
          handlerCallCount += 1
        }
    )

    var point = CGPoint(x: 0.0, y: 0.0)
    let targetContentOffset = withUnsafeMutablePointer(to: &point) { $0 }

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
