//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Foundation

/// A protocol that defines the functionality for storing the sizes of components.
public protocol ComponentSizeStorage {

  /// A typealias for a tuple containing a CGSize and AnyViewModel.
  typealias SizeContext = (size: CGSize, viewModel: AnyViewModel)

  /// Retrieves the size of a cell.
  /// - Parameter hash: The hash value of the cell.
  /// - Returns: The size context of the cell.
  func cellSize(for hash: AnyHashable) -> SizeContext?

  /// Retrieves the size of a header.
  /// - Parameter hash: The hash value of the header.
  /// - Returns: The size context of the header.
  func headerSize(for hash: AnyHashable) -> SizeContext?

  /// Retrieves the size of a footer.
  /// - Parameter hash: The hash value of the footer.
  /// - Returns: The size context of the footer.
  func footerSize(for hash: AnyHashable) -> SizeContext?

  /// Sets the size of a cell.
  /// - Parameters:
  ///   - size: The size context to set.
  ///   - hash: The hash value of the cell.
  func setCellSize(_ size: SizeContext, for hash: AnyHashable)

  /// Sets the size of a header.
  /// - Parameters:
  ///   - size: The size context to set.
  ///   - hash: The hash value of the header.
  func setHeaderSize(_ size: SizeContext, for hash: AnyHashable)

  /// Sets the size of a footer.
  /// - Parameters:
  ///   - size: The size context to set.
  ///   - hash: The hash value of the footer.
  func setFooterSize(_ size: SizeContext, for hash: AnyHashable)
}

final class ComponentSizeStorageImpl: ComponentSizeStorage {

  /// A dictionary to store the sizes of cells.
  var cellSizeStore = [AnyHashable: SizeContext]()

  /// A dictionary to store the sizes of headers.
  var headerSizeStore = [AnyHashable: SizeContext]()

  /// A dictionary to store the sizes of footers.
  var footerSizeStore = [AnyHashable: SizeContext]()

  func cellSize(for hash: AnyHashable) -> SizeContext? {
    cellSizeStore[hash]
  }

  func headerSize(for hash: AnyHashable) -> SizeContext? {
    headerSizeStore[hash]
  }

  func footerSize(for hash: AnyHashable) -> SizeContext? {
    footerSizeStore[hash]
  }

  func setCellSize(_ size: SizeContext, for hash: AnyHashable) {
    cellSizeStore[hash] = size
  }

  func setHeaderSize(_ size: SizeContext, for hash: AnyHashable) {
    headerSizeStore[hash] = size
  }

  func setFooterSize(_ size: SizeContext, for hash: AnyHashable) {
    footerSizeStore[hash] = size
  }
}
