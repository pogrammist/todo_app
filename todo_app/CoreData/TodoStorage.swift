import Foundation
import CoreData

protocol TodoStorageProtocol {
    func fetchAll(completion: @escaping (Result<[TodoItem], Error>) -> Void)
    func search(query: String, completion: @escaping (Result<[TodoItem], Error>) -> Void)
    func save(items: [TodoItem], completion: @escaping (Result<Void, Error>) -> Void)
    func upsert(item: TodoItem, completion: @escaping (Result<TodoItem, Error>) -> Void)
    func delete(id: Int64, completion: @escaping (Result<Void, Error>) -> Void)
    func count(completion: @escaping (Result<Int, Error>) -> Void)
}

final class TodoStorage: TodoStorageProtocol {
    private let stack: CoreDataStack
    private let queue: DispatchQueue

    init(stack: CoreDataStack = .shared, queue: DispatchQueue = DispatchQueue(label: "com.todo.storage", qos: .userInitiated)) {
        self.stack = stack
        self.queue = queue
    }

    func fetchAll(completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        runInBackground { ctx in
            let request = NSFetchRequest<TodoEntity>(entityName: "TodoEntity")
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            let objects = try ctx.fetch(request)
            let items = objects.map { TodoItem(managedObject: $0) }
            completion(.success(items))
        } failure: { error in
            completion(.failure(error))
        }
    }

    func search(query: String, completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        runInBackground { ctx in
            let request = NSFetchRequest<TodoEntity>(entityName: "TodoEntity")
            if !trimmed.isEmpty {
                request.predicate = NSPredicate(
                    format: "title CONTAINS[cd] %@ OR todoDescription CONTAINS[cd] %@",
                    trimmed, trimmed
                )
            }
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            let objects = try ctx.fetch(request)
            let items = objects.map { TodoItem(managedObject: $0) }
            completion(.success(items))
        } failure: { error in
            completion(.failure(error))
        }
    }

    func save(items: [TodoItem], completion: @escaping (Result<Void, Error>) -> Void) {
        runInBackground { ctx in
            for item in items {
                let entity = self.fetchOrCreate(id: item.id, in: ctx)
                entity.id = item.id
                entity.title = item.title
                entity.todoDescription = item.description
                entity.createdAt = item.createdAt
                entity.updatedAt = item.updatedAt
                entity.completed = item.completed
            }
            try ctx.save()
            completion(.success(()))
        } failure: { error in
            completion(.failure(error))
        }
    }

    func upsert(item: TodoItem, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        runInBackground { ctx in
            let entity = self.fetchOrCreate(id: item.id, in: ctx)
            entity.id = item.id
            entity.title = item.title
            entity.todoDescription = item.description
            entity.createdAt = item.createdAt
            entity.updatedAt = Date()
            entity.completed = item.completed
            try ctx.save()
            completion(.success(TodoItem(managedObject: entity)))
        } failure: { error in
            completion(.failure(error))
        }
    }

    func delete(id: Int64, completion: @escaping (Result<Void, Error>) -> Void) {
        runInBackground { ctx in
            let request = NSFetchRequest<TodoEntity>(entityName: "TodoEntity")
            request.predicate = NSPredicate(format: "id == %lld", id)
            if let obj = try ctx.fetch(request).first {
                ctx.delete(obj)
                try ctx.save()
            }
            completion(.success(()))
        } failure: { error in
            completion(.failure(error))
        }
    }

    func count(completion: @escaping (Result<Int, Error>) -> Void) {
        runInBackground { ctx in
            let request = NSFetchRequest<TodoEntity>(entityName: "TodoEntity")
            let c = try ctx.count(for: request)
            completion(.success(c))
        } failure: { error in
            completion(.failure(error))
        }
    }

    private func fetchOrCreate(id: Int64, in ctx: NSManagedObjectContext) -> TodoEntity {
        let request = NSFetchRequest<TodoEntity>(entityName: "TodoEntity")
        request.predicate = NSPredicate(format: "id == %lld", id)
        request.fetchLimit = 1
        if let existing = try? ctx.fetch(request).first {
            return existing
        }
        return TodoEntity(context: ctx)
    }

    private func runInBackground(_ block: @escaping (NSManagedObjectContext) throws -> Void,
                                 failure: @escaping (Error) -> Void) {
        let ctx = stack.newBackgroundContext()
        ctx.perform {
            do {
                try block(ctx)
            } catch {
                failure(error)
            }
        }
    }
}
