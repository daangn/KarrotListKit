//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Foundation

public protocol ComponentSizeStorage {
  typealias SizeContext = (size: CGSize, viewModel: AnyViewModel)

  var cellSizeStore: [AnyHashable: SizeContext] { get set }

  var headerSizeStore: [AnyHashable: SizeContext] { get set }

  var footerSizeStore: [AnyHashable: SizeContext] { get set }
}

struct ComponentSizeStorageImpl: ComponentSizeStorage {

  var cellSizeStore = [AnyHashable: SizeContext]()

  var headerSizeStore = [AnyHashable: SizeContext]()

  var footerSizeStore = [AnyHashable: SizeContext]()
}
