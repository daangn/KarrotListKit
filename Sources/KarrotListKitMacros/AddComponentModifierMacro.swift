//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

struct CustomError: Error {
  let message: String
}

public struct AddComponentModifierMacro: PeerMacro {

  public static func expansion(
    of node: SwiftSyntax.AttributeSyntax,
    providingPeersOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    // 단순 어노테이션 용도로만 사용, 아무것도 생성하지 않음
    return []
  }
}
