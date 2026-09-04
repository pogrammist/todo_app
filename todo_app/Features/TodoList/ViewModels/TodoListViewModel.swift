import Foundation
import Combine
import SwiftUI

final class TodoListViewModel: ObservableObject, TodoListPresenterProtocol {
    @Published var items: [TodoItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var path = NavigationPath()
    
    private let interactor: TodoListInteractorProtocol
    private let router: any TodoListRouterProtocol
    
    init(interactor: any TodoListInteractorProtocol, router: any TodoListRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }
    
    func viewDidLoad() {
        isLoading = true
        Task { @MainActor in
            do {
                items = try await interactor.loadTodos()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    func didTapAdd() {
        router.navigateToAdd(from: self)
    }
    
    func didTapEdit(_ item: TodoItem) {
        router.navigateToEdit(item, from: self)
    }
    
    func didTapDelete(_ item: TodoItem) {
        Task { @MainActor in
            do {
                try await interactor.deleteTodo(item)
                items.removeAll { $0.id == item.id }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func didToggle(_ item: TodoItem) {
        Task { @MainActor in
            do {
                let updated = try await interactor.toggleTodo(item)
                if let index = items.firstIndex(where: { $0.id == updated.id }) {
                    items[index] = updated
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func didSearch(query: String) {
        Task { @MainActor in
            do {
                if query.isEmpty {
                    items = try await interactor.loadTodos()
                } else {
                    items = try await interactor.searchTodos(query: query)
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
