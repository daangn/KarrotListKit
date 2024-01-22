//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

protocol ComponentRenderable: AnyObject {
  var componentContainerView: UIView { get }

  var renderedContent: UIView? { get set }

  var coordinator: Any? { get set }

  var renderedComponent: AnyComponent? { get set }

  func render(component: AnyComponent)
}

// MARK: - Det

extension ComponentRenderable where Self: UICollectionViewCell {
  var componentContainerView: UIView {
    contentView
  }
}

extension ComponentRenderable where Self: UICollectionReusableView {
  var componentContainerView: UIView {
    self
  }
}

extension ComponentRenderable where Self: UIView {

  func render(component: AnyComponent) {
    if let renderedContent {
      component.render(in: renderedContent, coordinator: coordinator ?? ())
      renderedComponent = component
    } else {
      coordinator = component.makeCoordinator()
      let content = component.renderContent(coordinator: coordinator ?? ())
      component.layout(content: content, in: componentContainerView)
      renderedContent = content
      render(component: component)
    }
  }
}
