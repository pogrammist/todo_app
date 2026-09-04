import Foundation

final class TodoListInteractor: TodoListInteractorProtocol {
    private let queue = DispatchQueue(label: "com.todo.list.interactor", qos: .userInitiated)
    
    func loadTodos() async throws -> [TodoItem] {
        try await withCheckedThrowingContinuation { continuation in
            queue.async {
                let sampleItems: [TodoItem] = [
                    TodoItem(id: 1, title: "Купить продукты", description: "Молоко, хлеб, яйца", createdAt: Date(), updatedAt: nil, completed: false),
                    TodoItem(id: 2, title: "Позвонить маме", description: "", createdAt: Date(), updatedAt: nil, completed: true),
                    TodoItem(id: 3, title: "Написать отчёт", description: "Еженедельный отчёт по проекту", createdAt: Date(), updatedAt: nil, completed: false)
                ]
                continuation.resume(returning: sampleItems)
            }
        }
    }
    
    func searchTodos(query: String) async throws -> [TodoItem] {
        try await withCheckedThrowingContinuation { continuation in
            queue.async {
                let allItems: [TodoItem] = [
                    TodoItem(id: 1, title: "Купить продукты", description: "Молоко, хлеб, яйца", createdAt: Date(), updatedAt: nil, completed: false),
                    TodoItem(id: 2, title: "Позвонить маме", description: "", createdAt: Date(), updatedAt: nil, completed: true),
                    TodoItem(id: 3, title: "Написать отчёт", description: "Еженедельный отчёт по проекту", createdAt: Date(), updatedAt: nil, completed: false)
                ]
                let filtered = allItems.filter {
                    $0.title.localizedCaseInsensitiveContains(query) ||
                    $0.description.localizedCaseInsensitiveContains(query)
                }
                continuation.resume(returning: filtered)
            }
        }
    }
    
    func toggleTodo(_ item: TodoItem) async throws -> TodoItem {
        try await withCheckedThrowingContinuation { continuation in
            queue.async {
                let updated = TodoItem(
                    id: item.id,
                    title: item.title,
                    description: item.description,
                    createdAt: item.createdAt,
                    updatedAt: Date(),
                    completed: !item.completed
                )
                continuation.resume(returning: updated)
            }
        }
    }
    
    func deleteTodo(_ item: TodoItem) async throws {
        try await withCheckedThrowingContinuation { continuation in
            queue.async {
                continuation.resume()
            }
        }
    }
}
