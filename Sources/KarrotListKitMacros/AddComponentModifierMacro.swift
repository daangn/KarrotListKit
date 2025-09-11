//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct AddComponentModifierMacro: PeerMacro {
  public static func expansion(
    of _: SwiftSyntax.AttributeSyntax,
    providingPeersOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    // struct 선언인지 확인
    guard
      let structDecl = context.lexicalContext.compactMap({ $0.as(StructDeclSyntax.self) }).first
    else {
      throw KarrotListKitMacroError(message: "@AddComponentModifier can only be applied to structs")
    }

    // 변수 선언인지 확인
    guard let varDecl = declaration.as(VariableDeclSyntax.self) else {
      return []
    }

    // var 키워드인지 확인
    guard varDecl.bindingSpecifier.tokenKind == .keyword(.var) else {
      return []
    }

    // 첫 번째 바인딩 가져오기
    guard
      let binding = varDecl.bindings.first,
      let identifier = binding.pattern.as(IdentifierPatternSyntax.self),
      let typeAnnotation = binding.typeAnnotation,
      let optionalType = typeAnnotation.type.as(OptionalTypeSyntax.self)
    else {
      return []
    }

    let propertyName = identifier.identifier.text

    // 클로저 타입인지 확인
    guard let functionType = convertToFunctionType(from: optionalType) else {
      return []
    }

    // struct의 access level 가져오기
    let structAccessLevel = structDecl.modifiers.first(where: { modifier in
      modifier.name.tokenKind == .keyword(.public) ||
      modifier.name.tokenKind == .keyword(.internal) ||
      modifier.name.tokenKind == .keyword(.fileprivate) ||
      modifier.name.tokenKind == .keyword(.private)
    })

    let accessLevelString: String = if let structAccessLevel {
      structAccessLevel.name.text + " "
    } else {
      ""
    }

    // 메서드 이름 생성 (Handler 접미사 제거)
    let methodName = propertyName.replacingOccurrences(of: "Handler", with: "")

    // 클로저 파라미터 분석 및 메서드 시그니처 생성
    let handlerType = functionType.description.trimmingCharacters(in: .whitespaces)

    let componentModifier = """
      \(accessLevelString)func \(methodName)(_ handler: @escaping \(handlerType)) -> Self {
        var copy = self
        copy.\(propertyName) = handler
        return copy
      }
      """

    return [
      DeclSyntax(stringLiteral: componentModifier),
    ]
  }

  private static func convertToFunctionType(
    from optionalType: OptionalTypeSyntax
  ) -> FunctionTypeSyntax? {
    guard
      let tupleType = optionalType.wrappedType.as(TupleTypeSyntax.self),
      tupleType.elements.count == 1,
      let firstElement = tupleType.elements.first
    else {
      return optionalType.wrappedType.as(FunctionTypeSyntax.self)
    }

    return firstElement.type.as(FunctionTypeSyntax.self)
  }
}
