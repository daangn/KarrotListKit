//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

import DifferenceKit

extension UICollectionView {
  func reload<C>(
    using stagedChangeset: StagedChangeset<C>,
    interrupt: ((Changeset<C>) -> Bool)? = nil,
    setData: (C) -> Void,
    enableReconfigure: Bool,
    completion: ((Bool) -> ())? = nil
  ) {
    if stagedChangeset.isEmpty {
      completion?(true)
      return
    }

    if case .none = window, let data = stagedChangeset.last?.data {
      setData(data)
      reloadData()
      layoutIfNeeded()
      completion?(true)
      return
    }

    for (index, changeset) in stagedChangeset.enumerated() {
      if let interrupt, interrupt(changeset), let data = stagedChangeset.last?.data {
        setData(data)
        reloadData()
        layoutIfNeeded()
        completion?(true)
        return
      }

      let isLastUpdate = index == (stagedChangeset.endIndex - 1)

      performBatchUpdates({
        setData(changeset.data)

        if !changeset.sectionDeleted.isEmpty {
          deleteSections(IndexSet(changeset.sectionDeleted))
        }

        if !changeset.sectionInserted.isEmpty {
          insertSections(IndexSet(changeset.sectionInserted))
        }

        if !changeset.sectionUpdated.isEmpty {
          reloadSections(IndexSet(changeset.sectionUpdated))
        }

        for (source, target) in changeset.sectionMoved {
          moveSection(source, toSection: target)
        }

        if !changeset.elementDeleted.isEmpty {
          deleteItems(at: changeset.elementDeleted.map { IndexPath(item: $0.element, section: $0.section) })
        }

        if !changeset.elementInserted.isEmpty {
          insertItems(at: changeset.elementInserted.map { IndexPath(item: $0.element, section: $0.section) })
        }

        if !changeset.elementUpdated.isEmpty {
          if #available(iOS 15.0, *), enableReconfigure {
            reconfigureItems(at: changeset.elementUpdated.map { IndexPath(item: $0.element, section: $0.section) })
          } else {
            reloadItems(at: changeset.elementUpdated.map { IndexPath(item: $0.element, section: $0.section) })
          }
        }

        for (source, target) in changeset.elementMoved {
          moveItem(
            at: IndexPath(item: source.element, section: source.section),
            to: IndexPath(item: target.element, section: target.section)
          )
        }
      }, completion: isLastUpdate ? completion : nil)
    }
  }
}

