//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Foundation

#if canImport(UIKit)
@attached(peer)
public macro AddComponentModifier() = #externalMacro(
  module: "KarrotListKitMacros",
  type: "AddComponentModifierMacro"
)
#endif
