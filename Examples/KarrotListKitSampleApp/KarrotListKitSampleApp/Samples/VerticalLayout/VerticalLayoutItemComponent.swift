//
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import KarrotListKit

@ListKitComponent
struct VerticalLayoutItemComponent {

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

//struct VerticalLayoutItemComponentV2: Component {
//
//  @AddComponentModifier
//  var onTapButtonHandler: (() -> Void)?
//
//  @AddComponentModifier
//  var onTapButtonWithValueHandler: ((Int) -> Void)?
//
//  @AddComponentModifier
//  var onTapButtonWithValuesHandler: ((Int, String) -> Void)?
//
//  @AddComponentModifier
//  var onTapButtonWithNamedValuesHandler: ((_ intValue Int, _ stringValue: String) -> Void)?
//}
//
//struct VerticalLayoutItemComponent: Component {
//
//  var onTapButtonHandler: (() -> Void)?
//  func onTapButton(_ handler: @escaping () -> Void) -> Self {
//    var copy = self
//    copy.onTapButtonHandler = handler
//    return copy
//  }
//
//  var onTapButtonWithValueHandler: ((Int) -> Void)?
//  func onTapButtonWithValue(_ handler: @escaping (Int) -> Void) -> Self {
//    var copy = self
//    copy.onTapButtonWithValueHandler = handler
//    return copy
//  }
//
//  var onTapButtonWithValuesHandler: ((Int, String) -> Void)?
//  func onTapButtonWithValues(_ handler: @escaping (Int, String) -> Void) -> Self {
//    var copy = self
//    copy.onTapButtonWithValuesHandler = handler
//    return copy
//  }
//
//  var onTapButtonWithNamedValuesHandler: ((_ intValue Int, _ stringValue: String) -> Void)?
//  func onTapButtonWithNamedValues(_ handler: @escaping (_ intValue: Int, _ stringValue: String) -> Void) -> Self {
//    var copy = self
//    copy.onTapButtonWithNamedValuesHandler = handler
//    return copy
//  }
//}
