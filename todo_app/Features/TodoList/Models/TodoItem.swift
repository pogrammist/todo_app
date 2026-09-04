import Foundation
import CoreData

struct TodoItem: Identifiable, Codable, Equatable, Hashable {
    let id: Int64
    var title: String
    var description: String
    var createdAt: Date
    var updatedAt: Date?
    var completed: Bool
    
    init(id: Int64, title: String, description: String, createdAt: Date, updatedAt: Date? = nil, completed: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.completed = completed
    }
    
    init(managedObject object: TodoEntity) {
        self.id = object.id
        self.title = object.title ?? ""
        self.description = object.todoDescription ?? ""
        self.createdAt = object.createdAt ?? Date()
        self.updatedAt = object.updatedAt
        self.completed = object.completed
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
