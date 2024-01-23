//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// chunks(ofCount:)
//===----------------------------------------------------------------------===//

/// A collection that presents the elements of its base collection in
/// `SubSequence` chunks of any given count.
///
/// A `ChunksOfCountCollection` is a lazy view on the base `Collection`, but it
/// does not implicitly confer laziness on algorithms applied to its result. In
/// other words, for ordinary collections `c`:ChunksOfCountCollection
///
/// * `c.chunks(ofCount: 3)` does not create new storage
/// * `c.chunks(ofCount: 3).map(f)` maps eagerly and returns a new array
/// * `c.lazy.chunks(ofCount: 3).map(f)` maps lazily and returns a
///   `LazyMapCollection`
struct ChunksOfCountCollection<Base: Collection> {
  typealias Element = Base.SubSequence

  @usableFromInline
  let base: Base

  @usableFromInline
  let chunkCount: Int

  @usableFromInline
  var endOfFirstChunk: Base.Index

  ///  Creates a view instance that presents the elements of `base` in
  ///  `SubSequence` chunks of the given count.
  ///
  /// - Complexity: O(*n*), because the start index is pre-computed.
  @inlinable
  init(_base: Base, _chunkCount: Int) {
    self.base = _base
    self.chunkCount = _chunkCount

    // Compute the start index upfront in order to make start index a O(1)
    // lookup.
    self.endOfFirstChunk = _base.index(
      _base.startIndex, offsetBy: _chunkCount,
      limitedBy: _base.endIndex
    ) ?? _base.endIndex
  }
}

extension ChunksOfCountCollection: Collection {
  struct Index {
    @usableFromInline
    let baseRange: Range<Base.Index>

    @inlinable
    init(_baseRange: Range<Base.Index>) {
      self.baseRange = _baseRange
    }
  }

  /// - Complexity: O(1)
  @inlinable
  var startIndex: Index {
    Index(_baseRange: base.startIndex..<endOfFirstChunk)
  }

  @inlinable
  var endIndex: Index {
    Index(_baseRange: base.endIndex..<base.endIndex)
  }

  /// - Complexity: O(1)
  @inlinable
  subscript(i: Index) -> Element {
    precondition(i != endIndex, "Index out of range")
    return base[i.baseRange]
  }

  @inlinable
  func index(after i: Index) -> Index {
    precondition(i != endIndex, "Advancing past end index")
    let baseIdx = base.index(
      i.baseRange.upperBound, offsetBy: chunkCount,
      limitedBy: base.endIndex
    ) ?? base.endIndex
    return Index(_baseRange: i.baseRange.upperBound..<baseIdx)
  }
}

extension ChunksOfCountCollection.Index: Comparable {
  @inlinable
  static func == (
    lhs: ChunksOfCountCollection.Index,
    rhs: ChunksOfCountCollection.Index
  ) -> Bool {
    lhs.baseRange.lowerBound == rhs.baseRange.lowerBound
  }

  @inlinable
  static func < (
    lhs: ChunksOfCountCollection.Index,
    rhs: ChunksOfCountCollection.Index
  ) -> Bool {
    lhs.baseRange.lowerBound < rhs.baseRange.lowerBound
  }
}

extension ChunksOfCountCollection:
  BidirectionalCollection, RandomAccessCollection
  where Base: RandomAccessCollection {
  @inlinable
  func index(before i: Index) -> Index {
    precondition(i != startIndex, "Advancing past start index")

    var offset = chunkCount
    if i.baseRange.lowerBound == base.endIndex {
      let remainder = base.count % chunkCount
      if remainder != 0 {
        offset = remainder
      }
    }

    let baseIdx = base.index(
      i.baseRange.lowerBound, offsetBy: -offset,
      limitedBy: base.startIndex
    ) ?? base.startIndex
    return Index(_baseRange: baseIdx..<i.baseRange.lowerBound)
  }
}

extension ChunksOfCountCollection {
  @inlinable
  func distance(from start: Index, to end: Index) -> Int {
    let distance =
      base.distance(
        from: start.baseRange.lowerBound,
        to: end.baseRange.lowerBound
      )
    let (quotient, remainder) =
      distance.quotientAndRemainder(dividingBy: chunkCount)
    return quotient + remainder.signum()
  }

  @inlinable
  var count: Int {
    let (quotient, remainder) =
      base.count.quotientAndRemainder(dividingBy: chunkCount)
    return quotient + remainder.signum()
  }

  @inlinable
  func index(
    _ i: Index, offsetBy offset: Int, limitedBy limit: Index
  ) -> Index? {
    guard offset != 0 else { return i }
    guard limit != i else { return nil }

    if offset > 0 {
      return limit > i
        ? offsetForward(i, offsetBy: offset, limit: limit)
        : offsetForward(i, offsetBy: offset)
    } else {
      return limit < i
        ? offsetBackward(i, offsetBy: offset, limit: limit)
        : offsetBackward(i, offsetBy: offset)
    }
  }

  @inlinable
  func index(_ i: Index, offsetBy distance: Int) -> Index {
    guard distance != 0 else { return i }

    let idx = distance > 0
      ? offsetForward(i, offsetBy: distance)
      : offsetBackward(i, offsetBy: distance)
    guard let index = idx else {
      fatalError("Out of bounds")
    }
    return index
  }

  @inlinable
  func offsetForward(
    _ i: Index, offsetBy distance: Int, limit: Index? = nil
  ) -> Index? {
    assert(distance > 0)

    return makeOffsetIndex(
      from: i, baseBound: base.endIndex,
      distance: distance, baseDistance: distance * chunkCount,
      limit: limit, by: >
    )
  }

  // Convenience to compute offset backward base distance.
  @inlinable
  func computeOffsetBackwardBaseDistance(
    _ i: Index, _ distance: Int
  ) -> Int {
    if i == endIndex {
      let remainder = base.count % chunkCount
      // We have to take it into account when calculating offsets.
      if remainder != 0 {
        // Distance "minus" one (at this point distance is negative) because we
        // need to adjust for the last position that have a variadic (remainder)
        // number of elements.
        return ((distance + 1) * chunkCount) - remainder
      }
    }
    return distance * chunkCount
  }

  @inlinable
  func offsetBackward(
    _ i: Index, offsetBy distance: Int, limit: Index? = nil
  ) -> Index? {
    assert(distance < 0)
    let baseDistance =
      computeOffsetBackwardBaseDistance(i, distance)
    return makeOffsetIndex(
      from: i, baseBound: base.startIndex,
      distance: distance, baseDistance: baseDistance,
      limit: limit, by: <
    )
  }

  // Helper to compute `index(offsetBy:)` index.
  @inlinable
  func makeOffsetIndex(
    from i: Index, baseBound: Base.Index, distance: Int, baseDistance: Int,
    limit: Index?, by limitFn: (Base.Index, Base.Index) -> Bool
  ) -> Index? {
    let baseIdx = base.index(
      i.baseRange.lowerBound, offsetBy: baseDistance,
      limitedBy: baseBound
    )

    if let limit {
      if baseIdx == nil {
        // If we passed the bounds while advancing forward, and the limit is the
        // `endIndex`, since the computation on `base` don't take into account
        // the remainder, we have to make sure that passing the bound was
        // because of the distance not just because of a remainder. Special
        // casing is less expensive than always using `count` (which could be
        // O(n) for non-random access collection base) to compute the base
        // distance taking remainder into account.
        if baseDistance > 0, limit == endIndex {
          if self.distance(from: i, to: limit) < distance {
            return nil
          }
        } else {
          return nil
        }
      }

      // Checks for the limit.
      let baseStartIdx = baseIdx ?? baseBound
      if limitFn(baseStartIdx, limit.baseRange.lowerBound) {
        return nil
      }
    }

    let baseStartIdx = baseIdx ?? baseBound
    let baseEndIdx = base.index(
      baseStartIdx, offsetBy: chunkCount, limitedBy: base.endIndex
    ) ?? base.endIndex

    return Index(_baseRange: baseStartIdx..<baseEndIdx)
  }
}

extension Collection {
  /// Returns a `ChunksOfCountCollection<Self>` view presenting the elements in
  /// chunks with count of the given count parameter.
  ///
  /// - Parameter count: The size of the chunks. If the `count` parameter is
  ///   evenly divided by the count of the base `Collection` all the chunks will
  ///   have the count equals to size. Otherwise, the last chunk will contain
  ///   the remaining elements.
  ///
  ///     let c = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  ///     print(c.chunks(ofCount: 5).map(Array.init))
  ///     // [[1, 2, 3, 4, 5], [6, 7, 8, 9, 10]]
  ///
  ///     print(c.chunks(ofCount: 3).map(Array.init))
  ///     // [[1, 2, 3], [4, 5, 6], [7, 8, 9], [10]]
  ///
  /// - Complexity: O(*n*), because the start index is pre-computed.
  func chunks(ofCount count: Int) -> ChunksOfCountCollection<Self> {
    precondition(count > 0, "Cannot chunk with count <= 0!")
    return ChunksOfCountCollection(_base: self, _chunkCount: count)
  }
}

extension ChunksOfCountCollection.Index: Hashable where Base.Index: Hashable {}

extension ChunksOfCountCollection:
  LazySequenceProtocol,
  LazyCollectionProtocol
  where Base: LazySequenceProtocol {}

extension Array {
  func chunks(ofCount count: Int) -> [[Element]] {
    let chunksOfCountCollection: ChunksOfCountCollection<Self> = chunks(ofCount: count)
    return chunksOfCountCollection.map(Array.init)
  }
}
