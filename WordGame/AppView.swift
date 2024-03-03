import SwiftUI
import ComposableArchitecture


@Reducer
struct Game {
    @Dependency(\.wordService) var wordService
    private let correctWordProbability: Double = 25.0
    
    @ObservableState
    struct State {
        var currentWordPair: WordPair = WordPair(word1: "", word2: "", isCorrect: true)
        var statistics: StatisticsState = .init()
    }
    
    enum Action: ViewAction {
        case view(View)
        case didReceiveWordPair(WordPair)
        
        enum View {
            case wrongButtonTapped
            case correctButtonTapped
            case task
        }
    }
    
    func loadWordPair() -> Effect<Action> {
        return .run { send in
            await send(.didReceiveWordPair(
                try await wordService.wordpair(percentage: correctWordProbability))
            )
        }
    }
    
    private func valid(state: State) -> Bool {
        if state.statistics.attemptsCounter >= 15 ||
            state.statistics.wrongAttemptsCounter >= 3 {
            return false
         }
        return true
    }
     
    func quitGame() -> Effect<Action> {
        exit(0)
    }
    
    var body: some Reducer<State, Action> {
        Reduce {
            state,
            action in
            switch action {
            case let .view(action):
                switch action {
                case .wrongButtonTapped:
                    if state.currentWordPair.isCorrect {
                        state.statistics.wrongAttemptsCounter+=1
                    } else {
                        state.statistics.correctAttemptsCounter+=1
                    }
                    if (!self.valid(state: state)) {
                        return self.quitGame()
                    }
                    
                    return self.loadWordPair()
                case .correctButtonTapped:
                    if state.currentWordPair.isCorrect {
                        state.statistics.correctAttemptsCounter+=1
                    } else {
                        state.statistics.wrongAttemptsCounter+=1
                    }
                    if (!self.valid(state: state)) {
                        return self.quitGame()
                    }
                    
                    return self.loadWordPair()
                case .task:
                    return self.loadWordPair()
                }
            case let .didReceiveWordPair(wordPair):
                state.currentWordPair = wordPair
                return .none
            }
        }
    }
}

@ViewAction(for: Game.self)
struct AppView: View {
    @Bindable var store: StoreOf<Game>
    
    var body: some View {
        VStack {
            Text("Correct Attempts: \(store.statistics.correctAttemptsCounter)")
                .frame(maxWidth: .infinity, alignment: .trailing)
            Text("Wrong Attempts: \(store.statistics.wrongAttemptsCounter)")
                .frame(maxWidth: .infinity, alignment: .trailing)
            Spacer()
            Text(store.currentWordPair.word2)
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .padding(20)
            Text(store.currentWordPair.word1)
                .font(.title3)
                .padding(20)
            Text(String(store.currentWordPair.isCorrect))
            Spacer()
            HStack {
                Button("Correct") { 
                    send(.correctButtonTapped)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                Button("Wrong") {
                    send(.wrongButtonTapped)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
        }
        .task {
            send(.task)
        }
        .padding()
    }
}

#Preview {
    AppView(
        store: Store(initialState: Game.State()) {
            Game()
        }
    )
}
