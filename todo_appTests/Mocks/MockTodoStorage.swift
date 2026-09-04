import Foundation
@testable import todo_app

final class MockTodoStorage: TodoStorageProtocol {
    var storedItems: [TodoItem] = []
    var fetchAllExpectation: ((@escaping (Result<[TodoItem], Error>) -> Void) -> Void)?
    
    func fetchAll(completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        if let exp = fetchAllExpectation {
            exp(completion)
        } else {
            completion(.success(storedItems))
        }
    }
    
    func search(query: String, completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            completion(.success(storedItems))
            return
        }
        let filtered = storedItems.filter {
            $0.title.localizedCaseInsensitiveContains(trimmed) ||
            $0.description.localizedCaseInsensitiveContains(trimmed)
        }
        completion(.success(filtered))
    }
    
    func save(items: [TodoItem], completion: @escaping (Result<Void, Error>) -> Void) {
        for item in items {
            if let idx = storedItems.firstIndex(where: { $0.id == item.id }) {
                storedItems[idx] = item
            } else {
                storedItems.append(item)
            }
        }
        completion(.success(()))
    }
    
    func upsert(item: TodoItem, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        if let idx = storedItems.firstIndex(where: { $0.id == item.id }) {
            storedItems[idx] = item
        } else {
            storedItems.append(item)
        }
        completion(.success(item))
    }
    
    func delete(id: Int64, completion: @escaping (Result<Void, Error>) -> Void) {
        storedItems.removeAll { $0.id == id }
        completion(.success(()))
    }
    
    func count(completion: @escaping (Result<Int, Error>) -> Void) {
        completion(.success(storedItems.count))
    }
}
