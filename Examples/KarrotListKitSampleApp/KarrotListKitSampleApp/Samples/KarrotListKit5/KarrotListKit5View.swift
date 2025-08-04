//
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import UIKit
import SwiftUI

import KarrotListKit5

struct Book {
  let id: UUID
  let title: String
}

final class KarrotListKit5View: UIView {

  var books: [Book] = [] {
    didSet {
      collectionViewAdapter.apply(list: compositionalLayoutList)
    }
  }

  private let collectionViewAdapter = CollectionViewAdapter<CompositionalLayout>()

  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(collectionViewAdapter.collectionView)
    collectionViewAdapter.collectionView.frame = bounds
    collectionViewAdapter.collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    defer {
      books = (0..<100).map {
        .init(id: UUID(), title: "\($0)")
      }
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  var compositionalLayoutList: KarrotListKit5.List<CompositionalLayout> {
    List {
      Section(
        id: 0,
        group: .horizontal(
          layoutSize: .init(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(50.0)
          ),
          repeatingSubitem: .init(
            layoutSize: .init(
              widthDimension: .fractionalWidth(0.5),
              heightDimension: .estimated(50.0)
            )
          ),
          count: 2
        )
      ) {
        for book in books {
          Item(id: book.id) {
            UIHostingConfiguration {
              Text(book.title)
            }
          }
          .didSelect { collectionView, indexPath in
            collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
          }
          .willDisplayCell { collectionView, cell, indexPath in
            print("willDisplayCell", indexPath)
          }
          .didEndDisplayingCell { collectionView, cell, indexPath in
            print("didEndDisplayingCell", indexPath)
          }
        }
      } boundarySupplementaryItems: {
        ElementKindGroup(.sectionHeader) {
          SupplementaryItem(
            layoutSize: .init(
              widthDimension: .fractionalWidth(1.0),
              heightDimension: .estimated(44.0)
            ),
            alignment: .top
          ) {
            UIHostingConfiguration {
              Text("Header")
            }
            .margins(.all, .zero)
          }
        }
      } decorationItems: {
        ElementKindGroup("background") {
          DecorationItem.background(viewClass: SectionBackgroundDecorationView.self)
        }
      }
      .contentInsets(
        NSDirectionalEdgeInsets(
          top: 8.0,
          leading: 8.0,
          bottom: 8.0,
          trailing: 8.0
        )
      )
    } boundarySupplementaryItems: {
      ElementKindGroup(.sectionHeader) {
        SupplementaryItem(
          layoutSize: .init(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44.0)
          ),
          alignment: .top
        ) {
          UIHostingConfiguration {
            Text("Global Header")
          }
          .margins(.all, .zero)
        }
      }
      ElementKindGroup(.sectionFooter) {
        SupplementaryItem(
          layoutSize: .init(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44.0)
          ),
          alignment: .bottom
        ) {
          UIHostingConfiguration {
            Text("Global Footer")
          }
          .margins(.all, .zero)
        }
      }
    }
    .scrollDirection(.vertical)
    .interSectionSpacing(8.0)
  }

  var flowLayoutList: KarrotListKit5.List<FlowLayout> {
    List {
      Section(id: 0) {
        for book in books {
          Item(id: book.id) {
            UIHostingConfiguration {
              Text(book.title)
            }
          }
          .size(.init(width: 50, height: 50))
          .didSelect { collectionView, indexPath in
            collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
          }
        }
      } header: {
        SupplementaryItem {
          UIHostingConfiguration {
            Text("Header")
          }
        }
      }
      .inset(.zero)
      .minimumLineSpacing(0.0)
      .minimumInteritemSpacing(0.0)
      .referenceSizeForHeader(.init(width: 0.0, height: 44.0))
    }
    .scrollDirection(.vertical)
    .estimatedItemSize(.zero)
  }
}

class SectionBackgroundDecorationView: UICollectionViewCell {

  override init(frame: CGRect) {
    super.init(frame: frame)
    contentConfiguration = UIHostingConfiguration {
      RoundedRectangle(cornerRadius: 8.0)
        .fill(.quinary)
    }
    .margins(.all, .zero)
  }

  required init?(coder: NSCoder) {
    fatalError("not implemented")
  }
}

@available(iOS 17.0, *)
#Preview {
  KarrotListKit5View()
}
