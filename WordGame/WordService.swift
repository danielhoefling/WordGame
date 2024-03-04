import Foundation
import ComposableArchitecture

@DependencyClient
struct WordService {
    var wordpair: (_ percentage: Double) -> WordPair?
}

extension WordService: DependencyKey {
    static let liveValue = Self(
        wordpair: { percentage in
            guard let translations = try? Bundle.main.decodeTranslations("words.json") else { return nil }
            let needCorrectWordPair = trueWithProbability(percentage: percentage)
            
            if (needCorrectWordPair) { //Get random word pair from translation list
                if let translation = translations.randomElement() {
                    return WordPair(word1: translation.text_eng, word2: translation.text_spa, isCorrect: true)
                }
            } else { //Get one word and another not matching word
                if let (firstWord, secondWord) = getRandomElements(from: translations) {
                    return WordPair(word1: firstWord.text_eng, word2: secondWord.text_spa, isCorrect: false)
                }
            }
            
            return nil
        }
    )
}

extension DependencyValues {
 var wordService: WordService {
  get { self[WordService.self] }
  set { self[WordService.self] = newValue }
 }
}

extension WordService: TestDependencyKey {
    public static let testValue = Self()
    
    /*public static let previewValue = Self(
        wordpair: {_ in .init(word1: "Word1", word2: "Word2", isCorrect: true)}
    )*/
}

enum BundleError: Error {
    case invalidResource
}

extension Bundle {
    func decodeTranslations(_ file: String) throws -> [TranslationPair] {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            throw BundleError.invalidResource
        }
                
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()

        return try decoder.decode([TranslationPair].self, from: data)
    }
}
