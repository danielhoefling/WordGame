import SwiftUI
import ComposableArchitecture


@Reducer
struct Game {
    @Dependency(\.wordService) var wordService
    
    @ObservableState
    struct State {
        var currentWordPair: WordPair = WordPair(word1: "", word2: "", isCorrect: true)
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
            Text("Correct Attempts: \(0)")
                .frame(maxWidth: .infinity, alignment: .trailing)
            Text("Wrong Attempts: \(0)")
                .frame(maxWidth: .infinity, alignment: .trailing)
            Spacer()
            Text("Word1")
            Text("Word2")
            Spacer()
            HStack {
                Button("Correct") { }
                Button("Wrong") { }
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
