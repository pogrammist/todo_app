import Foundation

final class TodoDetailInteractor: TodoDetailInteractorProtocol {
    private let queue = DispatchQueue(label: "com.todo.detail.interactor", qos: .userInitiated)
    private let storage: TodoStorageProtocol
    
    init(storage: TodoStorageProtocol = TodoStorage()) {
        self.storage = storage
    }
    
    func loadItem(id: Int64) async throws -> TodoItem? {
        try await withCheckedThrowingContinuation { continuation in
            queue.async { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: NSError(domain: "TodoDetailInteractor", code: -1))
                    return
                }
                self.storage.search(query: "") { result in
                    switch result {
                    case .success(let items):
                        if let item = items.first(where: { $0.id == id }) {
                            continuation.resume(returning: item)
                        } else {
                            continuation.resume(returning: nil)
                        }
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
    
    func saveItem(_ item: TodoItem) async throws -> TodoItem {
        try await withCheckedThrowingContinuation { continuation in
            queue.async { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: NSError(domain: "TodoDetailInteractor", code: -1))
                    return
                }
                self.storage.upsert(item: item) { result in
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
}
