import Foundation
import SwiftUI

// MARK: - View Protocol
protocol TodoDetailViewProtocol {
    func display(title: String, description: String)
    func displaySaveError(_ message: String)
}

// MARK: - Presenter Protocol
protocol TodoDetailPresenterProtocol: ObservableObject {
    var title: String { get }
    var description: String { get }
    var isEditing: Bool { get }
    
    func viewDidLoad()
    func save()
    func cancel()
}

// MARK: - Interactor Protocol
protocol TodoDetailInteractorProtocol {
    func loadItem(id: Int64) async throws -> TodoItem?
    func saveItem(_ item: TodoItem) async throws -> TodoItem
}

// MARK: - Router Protocol
protocol TodoDetailRouterProtocol: AnyObject {
    func dismiss()
}
