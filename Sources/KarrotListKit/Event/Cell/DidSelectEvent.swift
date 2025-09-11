//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Foundation

#if canImport(UIKit)

/// This structure encapsulates the selection event information and contains a closure object for handling the selection event.
public struct DidSelectEvent: ListingViewEvent {

  public struct EventContext {

    /// The index path of the cell that was selected.
    public let indexPath: IndexPath

    /// The component owned by the cell that was selected.
    public let anyComponent: AnyComponent
  }

  /// A closure that's called when the cell was selected
  let handler: (EventContext) -> Void
}
#endif
