import Foundation
import SwiftUI

final class TodoDetailViewModel: ObservableObject, TodoDetailPresenterProtocol {
    @Published var title: String = ""
    @Published var description: String = ""
    
    private let interactor: TodoDetailInteractorProtocol
    private let router: TodoDetailRouterProtocol
    private let existingItem: TodoItem?
    
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
    
    func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            // Will be handled by view
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
                router.dismiss()
            } catch {
                // Will be handled by view
            }
        }
    }
    
    func cancel() {
        router.dismiss()
    }
}
