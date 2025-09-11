//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct ListKitComponentMacro: MemberMacro, ExtensionMacro {
  
  // MARK: - MemberMacro
  
  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    // struct 선언인지 확인
    guard let structDecl = declaration.as(StructDeclSyntax.self) else {
      throw CustomError(message: "@ListKitComponent can only be applied to structs")
    }
    
    var modifierMethods: [DeclSyntax] = []
    
    // struct의 access level 가져오기
    let structAccessLevel = structDecl.modifiers.first(where: { modifier in
      return modifier.name.tokenKind == .keyword(.public) ||
             modifier.name.tokenKind == .keyword(.internal) ||
             modifier.name.tokenKind == .keyword(.fileprivate) ||
             modifier.name.tokenKind == .keyword(.private)
    })
    
    let accessLevelString: String
    if let structAccessLevel = structAccessLevel {
      accessLevelString = structAccessLevel.name.text + " "
    } else {
      // 기본값은 internal이지만, Swift에서는 명시하지 않음
      accessLevelString = ""
    }
    
    // 모든 멤버를 순회하면서 @AddComponentModifier가 있는 프로퍼티 찾기
    for member in structDecl.memberBlock.members {
      guard let varDecl = member.decl.as(VariableDeclSyntax.self) else {
        continue
      }
      
      // @AddComponentModifier 어노테이션이 있는지 확인
      let hasAddComponentModifier = varDecl.attributes.contains { attribute in
        guard case .attribute(let attr) = attribute,
              let identifier = attr.attributeName.as(IdentifierTypeSyntax.self) else {
          return false
        }
        return identifier.name.text == "AddComponentModifier"
      }
      
      guard hasAddComponentModifier else {
        continue
      }
      
      // var 키워드인지 확인
      guard varDecl.bindingSpecifier.tokenKind == .keyword(.var) else {
        continue
      }
      
      // 첫 번째 바인딩 가져오기
      guard let binding = varDecl.bindings.first,
            let identifier = binding.pattern.as(IdentifierPatternSyntax.self),
            let typeAnnotation = binding.typeAnnotation,
            let optionalType = typeAnnotation.type.as(OptionalTypeSyntax.self) else {
        continue
      }
      
      let propertyName = identifier.identifier.text
      
      // 클로저 타입인지 확인
      let functionType: FunctionTypeSyntax?
      if let tupleType = optionalType.wrappedType.as(TupleTypeSyntax.self),
         tupleType.elements.count == 1,
         let firstElement = tupleType.elements.first {
        functionType = firstElement.type.as(FunctionTypeSyntax.self)
      } else {
        functionType = optionalType.wrappedType.as(FunctionTypeSyntax.self)
      }
      
      guard let functionType = functionType else {
        continue
      }
      
      // 메서드 이름 생성 (Handler 접미사 제거)
      let methodName = propertyName.replacingOccurrences(of: "Handler", with: "")
      
      // 클로저 파라미터 분석 및 메서드 시그니처 생성
      let handlerType = functionType.description.trimmingCharacters(in: .whitespaces)
      
      // 메서드 생성 (struct의 access level과 동일하게)
      let method = """
        \(accessLevelString)func \(methodName)(_ handler: @escaping \(handlerType)) -> Self {
          var copy = self
          copy.\(propertyName) = handler
          return copy
        }
        """
      
      modifierMethods.append(DeclSyntax(stringLiteral: method))
    }
    
    return modifierMethods
  }
  
  // MARK: - ExtensionMacro
  
  public static func expansion(
    of node: AttributeSyntax,
    attachedTo declaration: some DeclGroupSyntax,
    providingExtensionsOf type: some TypeSyntaxProtocol,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [ExtensionDeclSyntax] {
    // struct 이름 가져오기
    guard let structDecl = declaration.as(StructDeclSyntax.self) else {
      throw CustomError(message: "@ListKitComponent can only be applied to structs")
    }
    
    let structName = structDecl.name.text
    
    // Component 프로토콜 준수 extension 생성
    let extensionDecl = try ExtensionDeclSyntax("extension \(raw: structName): Component {}")
    
    return [extensionDecl]
  }
}
