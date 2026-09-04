import Foundation
import SwiftUI

final class TodoListRouter: TodoListRouterProtocol {
    func navigateToAdd(from presenter: any TodoListPresenterProtocol) {
        presenter.path.append(TodoListRoute.add)
    }
    
    func navigateToEdit(_ item: TodoItem, from presenter: any TodoListPresenterProtocol) {
        presenter.path.append(TodoListRoute.edit(item))
    }
}
