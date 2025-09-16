//
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import KarrotListKit

struct VerticalLayoutItemComponent: Component {

  typealias ViewModel = VerticalLayoutItemView.ViewModel

  let viewModel: ViewModel

  @AddComponentModifier
  var onTapButtonHandler: (() -> Void)?

  @AddComponentModifier
  var onTapButtonWithValueHandler: ((Int) -> Void)?

  @AddComponentModifier
  var onTapButtonWithValuesHandler: ((Int, String) -> Void)?

  @AddComponentModifier
  var onTapButtonWithNamedValuesHandler: ((_ intValue: Int, _ stringValue: String) -> Void)?

  init(viewModel: ViewModel) {
    self.viewModel = viewModel
  }

  func renderContent(coordinator: ()) -> VerticalLayoutItemView {
    VerticalLayoutItemView(
      viewModel: viewModel
    )
  }

  func render(in content: VerticalLayoutItemView, coordinator: ()) {
    content.viewModel = viewModel
  }

  var layoutMode: ContentLayoutMode {
    .flexibleHeight(estimatedHeight: 54.0)
  }
}
