//
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

extension Character {
  static let lowercaseLetters: [Self] = (
    UnicodeScalar("a").value...UnicodeScalar("z").value
  ).compactMap { UnicodeScalar($0).flatMap(Character.init(_:)) }
}

extension String {
  static func randomWord(length: Int) -> Self {
    let characters = (0..<length).compactMap { _ in Character.lowercaseLetters.randomElement() }
    return String(characters)
  }

  static func randomWords(count: Int, wordLength: ClosedRange<Int>) -> Self {
    let words = (0..<count).map { _ in String.randomWord(length: .random(in: wordLength)) }
    return words.joined(separator: " ")
  }
}
