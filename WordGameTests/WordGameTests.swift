import XCTest
import ComposableArchitecture
@testable import WordGame

@MainActor
final class WordGameTests: XCTestCase {
    func testGameFlowTimerEllapsed() async {
        let store = TestStore(
            initialState: Game.State()
        ) {
            Game()
        }
        
        store.dependencies.wordService.wordpair = { _ in
            WordPair(word1: "Word1", word2: "Word2", isCorrect: true)
        }
        
        let testClock = TestClock()
        store.dependencies.continuousClock = testClock
        
        let task =  await store.send(.view(.task))
        await store.receive(\.didReceiveWordPair) {
            $0.currentWordPair = WordPair(word1: "Word1", word2: "Word2", isCorrect: true)
            $0.timerInfo.isTimerActive = true
        }
        
        await testClock.advance(by: .seconds(4))
        await store.receive(\.timerTicked) {
            $0.timerInfo.secondsElapsed = 1
        }
        await store.receive(\.timerTicked) {
            $0.timerInfo.secondsElapsed = 2
        }
        await store.receive(\.timerTicked) {
            $0.timerInfo.secondsElapsed = 3
        }
        await store.receive(\.timerTicked) {
            $0.timerInfo.secondsElapsed = 4
        }
        
        store.dependencies.wordService.wordpair = { _ in
            WordPair(word1: "Word3", word2: "Word4", isCorrect: true)
        }
        
        await testClock.advance(by: .seconds(1))
        await store.receive(\.timerTicked) {
            $0.timerInfo.secondsElapsed = 5
            $0.statistics.wrongAttemptsCounter = 1
        }
        
        await store.receive(\.didReceiveWordPair) {
            $0.currentWordPair = WordPair(word1: "Word3", word2: "Word4", isCorrect: true)
            $0.timerInfo.secondsElapsed = 0
        }
        
        await task.cancel()
    }
    
    func testGameFlowButtonTapped() async {
        let store = TestStore(
            initialState: Game.State()
        ) {
            Game()
        }
        
        store.dependencies.wordService.wordpair = { _ in
            WordPair(word1: "Word1", word2: "Word2", isCorrect: true)
        }
        
        let testClock = TestClock()
        store.dependencies.continuousClock = testClock
        
        let task = await store.send(.view(.task))
        await store.receive(\.didReceiveWordPair) {
            $0.currentWordPair = WordPair(word1: "Word1", word2: "Word2", isCorrect: true)
            $0.timerInfo.isTimerActive = true
        }
        
        store.dependencies.wordService.wordpair = { _ in
            WordPair(word1: "Word3", word2: "Word4", isCorrect: false)
        }
        
        let task2 = await store.send(.view(.correctButtonTapped)) {
            $0.statistics.correctAttemptsCounter = 1
        }
        
        await store.receive(\.didReceiveWordPair) {
            $0.currentWordPair = WordPair(word1: "Word3", word2: "Word4", isCorrect: false)
            $0.timerInfo.secondsElapsed = 0
        }
        
        store.dependencies.wordService.wordpair = { _ in
            WordPair(word1: "Word5", word2: "Word6", isCorrect: true)
        }
        
        let task3 = await store.send(.view(.correctButtonTapped)) {
            $0.statistics.wrongAttemptsCounter = 1
        }
        
        await store.receive(\.didReceiveWordPair) {
            $0.currentWordPair = WordPair(word1: "Word5", word2: "Word6", isCorrect: true)
            $0.timerInfo.secondsElapsed = 0
        }

        await task.cancel()
        await task2.cancel()
        await task3.cancel()
    }
}


                              
