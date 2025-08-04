//
//  CellContentRepresentable.swift
//  KarrotListKit
//
//  Created by Max.kim on 7/24/25.
//

import UIKit

public protocol CellContentRepresentable {

  associatedtype UIViewType: UIView
  associatedtype Coordinator = Void
  typealias Context = CellContentRepresentableContext<Self>

  func makeCoordinator() -> Self.Coordinator
  func makeUIView(context: Self.Context) -> Self.UIViewType
  func updateUIView(_ uiView: Self.UIViewType, context: Self.Context)
  static func dismantleUIView(_ uiView: Self.UIViewType, coordinator: Self.Coordinator)

  func preferredLayoutAttributesFitting(
    _ layoutAttributes: UICollectionViewLayoutAttributes,
    uiView: Self.UIViewType,
    context: Self.Context
  ) -> UICollectionViewLayoutAttributes
}

public struct CellContentRepresentableContext<Representable: CellContentRepresentable> {
  public let coordinator: Representable.Coordinator
}
