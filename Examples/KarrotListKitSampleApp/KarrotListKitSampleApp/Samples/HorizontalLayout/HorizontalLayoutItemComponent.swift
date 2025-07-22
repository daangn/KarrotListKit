//
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import KarrotListKit

struct HorizontalLayoutItemComponent: Component {
  typealias ViewModel = HorizontalLayoutItemView.ViewModel

  let viewModel: ViewModel

  init(viewModel: ViewModel) {
    self.viewModel = viewModel
  }

  func renderContent(coordinator: ()) -> HorizontalLayoutItemView {
    HorizontalLayoutItemView(
      viewModel: viewModel
    )
  }

  func render(in content: HorizontalLayoutItemView, coordinator: ()) {
    content.viewModel = viewModel
  }
}
