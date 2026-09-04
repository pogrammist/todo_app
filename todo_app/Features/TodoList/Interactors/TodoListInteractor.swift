import Foundation

final class TodoListInteractor: TodoListInteractorProtocol {
    private let queue = DispatchQueue(label: "com.todo.list.interactor", qos: .userInitiated)
    private let storage: TodoStorageProtocol
    private let api: TodoAPIClientProtocol
    
    init(storage: TodoStorageProtocol = TodoStorage(), api: TodoAPIClientProtocol = TodoAPIClient()) {
        self.storage = storage
        self.api = api
    }
    
    func loadTodos() async throws -> [TodoItem] {
        try await withCheckedThrowingContinuation { continuation in
            queue.async { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: NSError(domain: "TodoListInteractor", code: -1))
                    return
                }
                
                self.storage.count { countResult in
                    switch countResult {
                    case .success(let count):
                        if count == 0 {
                            Task { @MainActor in
                                do {
                                    let dtos = try await self.api.fetchTodos()
                                    let items = dtos.map { self.map(dto: $0) }
                                    self.storage.save(items: items) { saveResult in
                                        switch saveResult {
                                        case .success:
                                            self.storage.fetchAll { fetchResult in
                                                switch fetchResult {
                                                case .success(let items):
                                                    continuation.resume(returning: items)
                                                case .failure(let error):
                                                    continuation.resume(throwing: error)
                                                }
                                            }
                                        case .failure(let error):
                                            continuation.resume(throwing: error)
                                        }
                                    }
                                } catch {
                                    continuation.resume(throwing: error)
                                }
                            }
                        } else {
                            self.storage.fetchAll { fetchResult in
                                switch fetchResult {
                                case .success(let items):
                                    continuation.resume(returning: items)
                                case .failure(let error):
                                    continuation.resume(throwing: error)
                                }
                            }
                        }
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
    
    func searchTodos(query: String) async throws -> [TodoItem] {
        try await withCheckedThrowingContinuation { continuation in
            queue.async { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: NSError(domain: "TodoListInteractor", code: -1))
                    return
                }
                self.storage.search(query: query) { result in
                    switch result {
                    case .success(let items):
                        continuation.resume(returning: items)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
    
    func toggleTodo(_ item: TodoItem) async throws -> TodoItem {
        try await withCheckedThrowingContinuation { continuation in
            queue.async { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: NSError(domain: "TodoListInteractor", code: -1))
                    return
                }
                let updated = TodoItem(
                    id: item.id,
                    title: item.title,
                    description: item.description,
                    createdAt: item.createdAt,
                    updatedAt: Date(),
                    completed: !item.completed
                )
                self.storage.upsert(item: updated) { result in
                    switch result {
                    case .success(let saved):
                        continuation.resume(returning: saved)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
    
    func deleteTodo(_ item: TodoItem) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            queue.async { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: NSError(domain: "TodoListInteractor", code: -1))
                    return
                }
                self.storage.delete(id: item.id) { result in
                    switch result {
                    case .success:
                        continuation.resume()
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
    
    private func map(dto: TodoDTO) -> TodoItem {
        TodoItem(
            id: Int64(dto.id),
            title: dto.todo,
            description: "",
            createdAt: Date(),
            updatedAt: nil,
            completed: dto.completed
        )
    }
}
