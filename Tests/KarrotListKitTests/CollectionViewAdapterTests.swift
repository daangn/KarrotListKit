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
