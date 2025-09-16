//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Foundation

#if canImport(UIKit)
@attached(peer, names: arbitrary)
public macro AddComponentModifier() = #externalMacro(
  module: "KarrotListKitMacros",
  type: "AddComponentModifierMacro"
)
#endif
