//
//  File.swift
//  
//
//  Created by Jaxtyn on 2024/03/26.
//

import XCTest

@testable import KarrotListKit

final class RemoteImagePrefetchingPluginTest: XCTestCase {

  final class RemoteImagePrefetchingSpy: RemoteImagePrefetching {
    
    var prefetchImageCallCount: Int = 0
    func prefetchImage(url: URL) -> UUID? {
      prefetchImageCallCount += 1
      return UUID()
    }

    var cancelTaskCallCount: Int = 0
    func cancelTask(uuid: UUID) {
      cancelTaskCallCount += 1
    }
  }

  struct ComponentRemoteImagePrefetchableDummy: ComponentRemoteImagePrefetchable {
    
    var remoteImageURLs: [URL] {
      [
        URL(string: "https://github.com/daangn/KarrotListKit")!
      ]
    }
  }

  func test_given_imagePrefetchable_when_prefetch_then_fetch_image() {
    // given
    let imagePrefetcher = RemoteImagePrefetchingSpy()
    let sut = RemoteImagePrefetchingPlugin(
      remoteImagePrefetcher: imagePrefetcher
    )

    // when
    _ = sut.prefetch(with: ComponentRemoteImagePrefetchableDummy())

    // then
    XCTAssertEqual(imagePrefetcher.prefetchImageCallCount, 1)
  }

  func test_given_taskCancellable_when_cancel_prefetch_then_cancel_task() {
    // given
    let imagePrefetcher = RemoteImagePrefetchingSpy()
    let sut = RemoteImagePrefetchingPlugin(
      remoteImagePrefetcher: imagePrefetcher
    )
    let cancellable = sut.prefetch(with: ComponentRemoteImagePrefetchableDummy())

    // when
    cancellable?.cancel()

    // then
    XCTAssertEqual(imagePrefetcher.cancelTaskCallCount, 1)
  }
}
