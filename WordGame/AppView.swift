import SwiftUI
import ComposableArchitecture


@Reducer
struct Game {
    @Dependency(\.wordService) var wordService
    @Dependency(\.continuousClock) var clock
    private let correctWordProbability: Double = 25.0
    private let secondsToAnswer: Int = 5
    private let allowedIncorrectAttempts: Int = 3
    private let allowedWordPairs: Int = 15
    
    @ObservableState
    struct State {
        var currentWordPair: WordPair = WordPair(word1: "", word2: "", isCorrect: true)
        var statistics: StatisticsState = .init()
        var timerInfo: TimerInfoState = .init()
        var isDialogPresented: Bool = false
    }
    
    private enum CancelID {
        case timer
    }
    
    enum Action: BindableAction, ViewAction {
        case binding(BindingAction<State>)
        case view(View)
        case didReceiveWordPair(WordPair)
        case timerTicked
        
        enum View {
            case wrongButtonTapped
            case correctButtonTapped
            case restartButtonTapped
            case task
            case quitGame
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
        if state.statistics.attemptsCounter >= allowedWordPairs ||
            state.statistics.wrongAttemptsCounter >= allowedIncorrectAttempts {
            return false
         }
        return true
    }
     
    func gameEnded(state: inout State) -> Effect<Action> {
        state.isDialogPresented = true
        state.timerInfo.secondsElapsed = 0
        state.timerInfo.isTimerActive = false
        return .cancel(id: CancelID.timer)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce {
            state,
            action in
            switch action {
            case .binding:
                return .none
            case let .view(action):
                switch action {
                case .wrongButtonTapped:
                    if state.currentWordPair.isCorrect {
                        state.statistics.wrongAttemptsCounter+=1
                    } else {
                        state.statistics.correctAttemptsCounter+=1
                    }
                    if (!self.valid(state: state)) {
                        return self.gameEnded(state: &state)
                    }
                    
                    return self.loadWordPair()
                case .correctButtonTapped:
                    if state.currentWordPair.isCorrect {
                        state.statistics.correctAttemptsCounter+=1
                    } else {
                        state.statistics.wrongAttemptsCounter+=1
                    }
                    if (!self.valid(state: state)) {
                        return self.gameEnded(state: &state)
                    }
                    
                    return self.loadWordPair()
                case .task:
                    return self.loadWordPair()
                case .restartButtonTapped:
                    state.statistics.correctAttemptsCounter = 0
                    state.statistics.wrongAttemptsCounter = 0
                    return self.loadWordPair()
                case .quitGame:
                    exit(0)
                }
            case let .didReceiveWordPair(wordPair):
                state.currentWordPair = wordPair
                state.timerInfo.isTimerActive = true
                state.timerInfo.secondsElapsed = 0
                
                return .run { [isTimerActive = state.timerInfo.isTimerActive] send in
                    guard isTimerActive else { return }
                    for await _ in self.clock.timer(interval: .seconds(1)) {
                        await send(.timerTicked, animation: .interpolatingSpring(stiffness: 3000, damping: 40))
                    }
                }
                .cancellable(id: CancelID.timer, cancelInFlight: true)
            case .timerTicked:
                state.timerInfo.secondsElapsed += 1
                if (state.timerInfo.secondsElapsed >= secondsToAnswer) {
                    state.statistics.wrongAttemptsCounter+=1
                    if (!self.valid(state: state)) {
                        return self.gameEnded(state: &state)
                    }
                    
                    return self.loadWordPair()
                }
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
            .confirmationDialog("Change background", isPresented: $store.isDialogPresented) {
                Button("Restart") {
                    send(.restartButtonTapped)
                }
                Button("Quit") { 
                    send(.quitGame)
                }
            } message: {
                VStack {
                    Text("Final Score: Correct Attempts: \(store.statistics.correctAttemptsCounter) Wrong Attempts: \(store.statistics.wrongAttemptsCounter)")
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
