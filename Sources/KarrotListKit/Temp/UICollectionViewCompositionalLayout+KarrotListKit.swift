//
//  File.swift
//  KarrotListKit
//
//  Created by Ben on 7/24/25.
//

import UIKit

// MARK: - UICollectionViewCompositionalLayout

extension UICollectionViewCompositionalLayout {

  // MARK: Public

  /// Vends a compositional layout that has its section layout determined by invoking the
  /// `layoutSectionProvider` of its `CollectionView`'s corresponding `SectionModel` for each
  /// section.
  public static var proxy: UICollectionViewCompositionalLayout {
    proxy { provider in
      UICollectionViewCompositionalLayout(sectionProvider: provider)
    }
  }

  /// Vends a compositional layout that has its section layout determined by invoking the
  /// `layoutSectionProvider` of its `CollectionView`'s corresponding `SectionModel` for each
  /// section.
  public static func proxy(
    configuration: UICollectionViewCompositionalLayoutConfiguration)
  -> UICollectionViewCompositionalLayout
  {
    proxy { provider in
      UICollectionViewCompositionalLayout(sectionProvider: provider, configuration: configuration)
    }
  }

  // MARK: Private

  private typealias MakeLayout = (
    @escaping UICollectionViewCompositionalLayoutSectionProvider
  ) -> UICollectionViewCompositionalLayout

  private static func proxy(_ makeLayout: MakeLayout) -> UICollectionViewCompositionalLayout
  {
    weak var layoutReference: UICollectionViewCompositionalLayout?

    let provider: UICollectionViewCompositionalLayoutSectionProvider = { index, environment in
      guard let collectionView = layoutReference?.collectionView as? CollectionView else {
        return nil
      }

      return collectionView.sectionItem(at: index)?.layout(index: index, environment: environment)
    }

    let layout = makeLayout(provider)

    layoutReference = layout

    return layout
  }
}
