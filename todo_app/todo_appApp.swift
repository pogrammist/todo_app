import SwiftUI

@main
struct todo_appApp: App {
    var body: some Scene {
        WindowGroup {
            TodoListView(
                viewModel: TodoListViewModel(
                    interactor: TodoListInteractor(),
                    router: TodoListRouter()
                )
            )
        }
    }
}
