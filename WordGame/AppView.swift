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
    struct State: Equatable {
        var currentWordPair: WordPair?
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
        if let wordPair = wordService.wordpair(percentage: correctWordProbability) {
            return .send(.didReceiveWordPair(wordPair))
        }
        
        return .none
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
                    if state.currentWordPair?.isCorrect == true {
                        state.statistics.wrongAttemptsCounter+=1
                    } else {
                        state.statistics.correctAttemptsCounter+=1
                    }
                    if (!self.valid(state: state)) {
                        return self.gameEnded(state: &state)
                    }
                    
                    return self.loadWordPair()
                case .correctButtonTapped:
                    if state.currentWordPair?.isCorrect == true {
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
                    //fatalError("Crash on acceptance criteria.")
                }
            case let .didReceiveWordPair(wordPair):
                state.currentWordPair = wordPair
                state.timerInfo.isTimerActive = true
                state.timerInfo.secondsElapsed = 0
                
                return .run { [isTimerActive = state.timerInfo.isTimerActive] send in
                    guard isTimerActive else { return }
                    for await _ in self.clock.timer(interval: .seconds(1)) {
                        await send(.timerTicked)
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
    private let textColor: Color = Color(UIColor.darkGray)
    
    var body: some View {
        VStack {
            Text("Correct Attempts: \(store.statistics.correctAttemptsCounter)")
                .frame(maxWidth: .infinity, alignment: .trailing)
                .foregroundColor(textColor)
            Text("Wrong Attempts: \(store.statistics.wrongAttemptsCounter)")
                .frame(maxWidth: .infinity, alignment: .trailing)
                .foregroundColor(textColor)
            Spacer()
            if let pair = store.currentWordPair {
                Text(pair.word2)
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .foregroundColor(textColor)
                    .padding(20)
                Text(pair.word1)
                    .font(.title3)
                    .foregroundColor(textColor)
                    .padding(20)
            }
            Spacer()
            HStack {
                Button() {
                    send(.correctButtonTapped)
                }
                label: {
                    Text("Correct")
                        .padding()
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(
                                cornerRadius: 20,
                                style: .continuous
                            )
                            .fill(.green)
                        )
                }
                .font(.title2)
                .padding()
                Button() {
                    send(.wrongButtonTapped)
                }
            label: {
                Text("Wrong")
                    .padding()
                    .foregroundColor(.white)
                    .background(
                        RoundedRectangle(
                            cornerRadius: 20,
                            style: .continuous
                        )
                        .fill(.red)
                    )
            }
            .font(.title2)
            }
            .confirmationDialog("Change background", isPresented: $store.isDialogPresented) {
                Button("Restart") {
                    send(.restartButtonTapped)
                }
                Button("Quit", role: .cancel) {
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
