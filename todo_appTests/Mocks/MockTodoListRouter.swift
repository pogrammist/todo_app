import Foundation
@testable import todo_app

final class MockTodoListRouter: TodoListRouterProtocol {
    var navigateToAddCalled = false
    var navigateToEditCalled = false
    var editedItem: TodoItem?
    
    func navigateToAdd(from presenter: any TodoListPresenterProtocol) {
        navigateToAddCalled = true
    }
    
    func navigateToEdit(_ item: TodoItem, from presenter: any TodoListPresenterProtocol) {
        navigateToEditCalled = true
        editedItem = item
    }
}
