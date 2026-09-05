import Foundation
import SwiftUI

final class TodoDetailViewModel: ObservableObject, TodoDetailPresenterProtocol {
    @Published var title: String = ""
    @Published var description: String = ""
    
    let existingItem: TodoItem?
    
    private let interactor: TodoDetailInteractorProtocol
    private let router: TodoDetailRouterProtocol
    private var saveTask: Task<Void, Never>?
    
    var isEditing: Bool { existingItem != nil }
    
    init(interactor: TodoDetailInteractorProtocol, router: TodoDetailRouterProtocol, item: TodoItem? = nil) {
        self.interactor = interactor
        self.router = router
        self.existingItem = item
    }
    
    func viewDidLoad() {
        if let item = existingItem {
            title = item.title
            description = item.description
        }
    }
    
    func scheduleSave() {
        saveTask?.cancel()
        saveTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 400_000_000)
            guard !Task.isCancelled else { return }
            let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedTitle.isEmpty else { return }
            do {
                let item = TodoItem(
                    id: existingItem?.id ?? Int64(Date().timeIntervalSince1970 * 1000),
                    title: trimmedTitle,
                    description: description,
                    createdAt: existingItem?.createdAt ?? Date(),
                    updatedAt: Date(),
                    completed: existingItem?.completed ?? false
                )
                _ = try await interactor.saveItem(item)
            } catch {
                // silently ignore background save errors
            }
        }
    }
    
    func save() {
        save { _ in }
    }
    
    func save(completion: @escaping (Bool) -> Void = { _ in }) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            completion(false)
            return
        }
        
        Task { @MainActor in
            do {
                let item = TodoItem(
                    id: existingItem?.id ?? Int64(Date().timeIntervalSince1970 * 1000),
                    title: trimmedTitle,
                    description: description,
                    createdAt: existingItem?.createdAt ?? Date(),
                    updatedAt: Date(),
                    completed: existingItem?.completed ?? false
                )
                _ = try await interactor.saveItem(item)
                completion(true)
            } catch {
                completion(false)
            }
        }
    }
    
    func cancel() {
        // no-op, dismiss handled by view
    }
}
