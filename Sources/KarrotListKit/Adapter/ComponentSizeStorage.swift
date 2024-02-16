//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Foundation

import CoreGraphics

public protocol ComponentSizeStorage {
  func cellSize(for cell: Cell) -> CGSize?

  func footerSize(for section: Section) -> CGSize?

  func headerSize(for section: Section) -> CGSize?
}

struct ComponentSizeStorageImpl: ComponentSizeStorage {

  private var modeCalculator = [AnyHashable: ModeCalculator]()

  private var cellSizeStore = [AnyHashable: Context]()

  private var headerSizeStore = [AnyHashable: Context]()

  private var footerSizeStore = [AnyHashable: Context]()

  // MARK: - ComponentSizeStorage

  func cellSize(for cell: Cell) -> CGSize? {
    guard let context = cellSizeStore[cell.id],
          context.component.viewModel == cell.component.viewModel else {
      return modeCalculator[cell.component.reuseIdentifier]?.mode?.toCGSize()
    }

    return context.size
  }

  func footerSize(for section: Section) -> CGSize? {
    guard let context = footerSizeStore[section.id],
          let footer = section.footer,
          context.component.viewModel == footer.component.viewModel else {
      return modeCalculator[section.footer?.component.reuseIdentifier ?? ""]?.mode?.toCGSize()
    }

    return context.size
  }

  func headerSize(for section: Section) -> CGSize? {
    guard let context = headerSizeStore[section.id],
          let header = section.header,
          context.component.viewModel == header.component.viewModel else {
      return modeCalculator[section.header?.component.reuseIdentifier ?? ""]?.mode?.toCGSize()
    }

    return context.size
  }

  mutating func setCellSize(_ sizeContext: Context) {
    saveComponentSize(sizeContext)
    cellSizeStore[sizeContext.id] = sizeContext
  }

  mutating func setHeaderSize(_ sizeContext: Context) {
    saveComponentSize(sizeContext)
    headerSizeStore[sizeContext.id] = sizeContext
  }

  mutating func setFooterSize(_ sizeContext: Context) {
    saveComponentSize(sizeContext)
    footerSizeStore[sizeContext.id] = sizeContext
  }

  private mutating func saveComponentSize(_ sizeContext: Context) {
    let id = sizeContext.component.reuseIdentifier
    var modeCalculator = modeCalculator[id] ?? ModeCalculator()
    modeCalculator.insert(.init(width: sizeContext.size.width, height: sizeContext.size.height))
    self.modeCalculator[id] = modeCalculator
  }
}

extension ComponentSizeStorageImpl {

  struct Size: Hashable {
    let width: Double
    let height: Double

    static func ==(lhs: Size, rhs: Size) -> Bool {
      lhs.width == rhs.width && lhs.height == rhs.height
    }

    func hash(into hasher: inout Hasher) {
      hasher.combine(width)
      hasher.combine(height)
    }

    func toCGSize() -> CGSize {
      return .init(width: width, height: height)
    }
  }

  struct Context {
    let id: AnyHashable
    let size: CGSize
    let component: AnyComponent

    init(
      id: AnyHashable,
      size: CGSize,
      component: AnyComponent
    ) {
      self.id = id
      self.size = size
      self.component = component
    }
  }

  struct ModeCalculator {
    private var frequency: [Size: Int] = [:]

    mutating func insert(_ element: Size) {
      let count = (frequency[element] ?? 0) + 1
      frequency[element] = count
    }

    var mode: Size? {
      return frequency.max { a, b in a.value < b.value }?.key
    }
  }
}
