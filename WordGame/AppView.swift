import SwiftUI
import ComposableArchitecture


@Reducer
struct Game {
    @Dependency(\.wordService) var wordService
    
    @ObservableState
    struct State {
        var currentWordPair: WordPair = WordPair(word1: "Test", word2: "Test2", isCorrect: true)
        var statistics: StatisticsState = .init()
    }
    
    enum Action: ViewAction {
        case view(View)

        enum View {
            case wrongButtonTapped
            case correctButtonTapped
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
                        .none
                case .correctButtonTapped:
                        .none
                }
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
            Text(store.currentWordPair.word1)
            Text(store.currentWordPair.word2)
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
