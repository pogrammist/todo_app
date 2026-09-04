import Foundation
@testable import todo_app

final class MockTodoAPIClient: TodoAPIClientProtocol {
    var result: Result<[TodoDTO], Error> = .success([])
    
    func fetchTodos() async throws -> [TodoDTO] {
        switch result {
        case .success(let dtos):
            return dtos
        case .failure(let error):
            throw error
        }
    }
}
