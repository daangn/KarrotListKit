//
//  ElementKind.swift
//  KarrotListKit
//
//  Created by Max.kim on 8/1/25.
//

import UIKit

public struct ElementKind: Hashable, RawRepresentable, ExpressibleByStringLiteral {

  public let rawValue: String

  public init(rawValue: String) {
    self.rawValue = rawValue
  }

  public init(stringLiteral value: StringLiteralType) {
    self.init(rawValue: value)
  }

  public static let sectionHeader = Self(rawValue: UICollectionView.elementKindSectionHeader)
  public static let sectionFooter = Self(rawValue: UICollectionView.elementKindSectionFooter)
}

public struct ElementKindGroup<Item> {

  public let elementKind: ElementKind
  public let items: [Item]

  public init<LayoutValue>(
    _ elementKind: ElementKind,
    @SupplementaryItemsBuilder<SupplementaryItem<LayoutValue>> supplementaryItems: () -> [SupplementaryItem<LayoutValue>]
  ) where Item == SupplementaryItem<LayoutValue> {
    self.elementKind = elementKind
    self.items = supplementaryItems()
  }

  public init<LayoutValue>(
    _ elementKind: ElementKind,
    @DecorationItemsBuilder<DecorationItem<LayoutValue>> decorationItems: () -> [DecorationItem<LayoutValue>]
  ) where Item == DecorationItem<LayoutValue> {
    self.elementKind = elementKind
    self.items = decorationItems()
  }
}
