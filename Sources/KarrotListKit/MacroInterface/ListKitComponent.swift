//
//  Copyright (c) 2025 Danggeun Market Inc.
//

import Foundation

#if canImport(UIKit)
@attached(extension, conformances: Component)
@attached(member, names: arbitrary)
public macro ListKitComponent() = #externalMacro(
  module: "KarrotListKitMacros",
  type: "ListKitComponentMacro"
)
#endif
