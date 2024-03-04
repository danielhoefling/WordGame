import SwiftUI
import ComposableArchitecture

@main
struct WordGameApp: App {
    var body: some Scene {
        WindowGroup {
            AppView(
                store: Store(initialState: Game.State()) {
                    Game()
                }
            )
        }
    }
}
