import SwiftUI
import ComposableArchitecture


@Reducer
struct Game {
    @Dependency(\.wordService) var wordService
    let correctWordProbability: Double = 25.0
    
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
    
    var body: some Reducer<State, Action> {
        Reduce {
            state,
            action in
            switch action {
            case let .view(action):
                switch action {
                case .wrongButtonTapped:
                       return .none
                case .correctButtonTapped:
                       return .none
                case .task:
                    return .run { send in
                        await send(.didReceiveWordPair(try await wordService.wordpair(correctWordProbability)))
                    }
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
            Text(store.currentWordPair.word1)
            Spacer()
            HStack {
                Button("Correct") { 
                    send(.correctButtonTapped)
                }
                Button("Wrong") { 
                    send(.wrongButtonTapped)
                }
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
