import Foundation
import Combine
import SwiftUI

// MARK: - View Protocol
protocol TodoListViewProtocol {
    func display(items: [TodoItem])
    func showLoading(_ loading: Bool)
    func display(error: String)
}

// MARK: - Presenter Protocol
protocol TodoListPresenterProtocol: ObservableObject {
    var items: [TodoItem] { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    var path: NavigationPath { get set }
    
    func viewDidLoad()
    func didTapAdd()
    func didTapEdit(_ item: TodoItem)
    func didTapDelete(_ item: TodoItem)
    func didToggle(_ item: TodoItem)
    func didSearch(query: String)
}

// MARK: - Interactor Protocol
protocol TodoListInteractorProtocol {
    func loadTodos() async throws -> [TodoItem]
    func searchTodos(query: String) async throws -> [TodoItem]
    func toggleTodo(_ item: TodoItem) async throws -> TodoItem
    func deleteTodo(_ item: TodoItem) async throws
}

// MARK: - Router Protocol
protocol TodoListRouterProtocol: AnyObject {
    func navigateToAdd(from presenter: any TodoListPresenterProtocol)
    func navigateToEdit(_ item: TodoItem, from presenter: any TodoListPresenterProtocol)
}

// MARK: - Route
enum TodoListRoute: Hashable {
    case add
    case edit(TodoItem)
}
