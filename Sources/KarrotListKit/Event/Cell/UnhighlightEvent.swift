//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

/// This structure encapsulates the unhighlight event information and contains a closure object for handling the unhighlight event.
public struct UnhighlightEvent: ListingViewEvent {

  public struct EventContext {

    /// The index path of the view that was unhighlight.
    public let indexPath: IndexPath

    /// The component owned by the view that was unhighlight.
    public let anyComponent: AnyComponent

    /// The content owned by the view that was unhighlight.
    public let content: UIView?
  }

  /// A closure that's called when the cell was unhighlight
  let handler: (EventContext) -> Void
}

