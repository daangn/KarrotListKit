//
//  DecorationItem.swift
//  KarrotListKit
//
//  Created by Max.kim on 7/31/25.
//

import UIKit

public protocol DecorationItemProtocol<LayoutValues> {
  associatedtype LayoutValues
  var viewClass: UICollectionReusableView.Type { get }
  var layoutValues: LayoutValues { get }
}

public struct DecorationItem<LayoutValues>: DecorationItemProtocol {

  public let viewClass: UICollectionReusableView.Type
  public var layoutValues: LayoutValues

  public init<ViewClass: UICollectionReusableView>(
    viewClass: ViewClass.Type,
    layoutValues: LayoutValues
  ) {
    self.viewClass = viewClass
    self.layoutValues = layoutValues
  }

  public init<ViewClass: UICollectionReusableView>(
    viewClass: ViewClass.Type
  ) where LayoutValues == Void {
    self.init(
      viewClass: viewClass,
      layoutValues: ()
    )
  }
}
