import Foundation

struct TodoItem: Identifiable, Codable, Equatable, Hashable {
    let id: Int64
    var title: String
    var description: String
    var createdAt: Date
    var updatedAt: Date?
    var completed: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
