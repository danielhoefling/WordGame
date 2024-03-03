import Foundation
import ComposableArchitecture

@DependencyClient
struct WordService {
    var wordpair: () async throws -> WordPair
}

extension WordService: DependencyKey {
    static let liveValue = Self(
        wordpair: {
            let translations = Bundle.main.decodeTranslations("words.json")
            
            return WordPair(word1: "", word2: "", isCorrect: true)
        }
    )
}

extension DependencyValues {
 var wordService: WordService {
  get { self[WordService.self] }
  set { self[WordService.self] = newValue }
 }
}

extension Bundle {
    func decodeTranslations(_ file: String) -> [TranslationPair] {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }

        let decoder = JSONDecoder()

        guard let loaded = try? decoder.decode([TranslationPair].self, from: data) else {
            fatalError("Failed to decode \(file) from bundle.")
        }

        return loaded
    }
}