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
        
        await store.send(.view(.correctButtonTapped)) {
            $0.statistics.correctAttemptsCounter = 1
        }
        
        await store.receive(\.didReceiveWordPair)
        
        await store.send(.view(.wrongButtonTapped)) {
            $0.statistics.wrongAttemptsCounter = 1
        }
        
        await store.receive(\.didReceiveWordPair)
        
        await store.send(.view(.wrongButtonTapped)) {
            $0.statistics.wrongAttemptsCounter = 2
        }
        
        await store.receive(\.didReceiveWordPair)
        
        await store.send(.view(.wrongButtonTapped)) {
            $0.statistics.wrongAttemptsCounter = 3
            $0.timerInfo.isTimerActive = false
            $0.isDialogPresented = true
        }
        
        await task.cancel()

    }
}


                              
