import Foundation

struct TodoDTO: Decodable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int?
}

struct TodosResponse: Decodable {
    let todos: [TodoDTO]
    let total: Int?
    let skip: Int?
    let limit: Int?
}

protocol TodoAPIClientProtocol {
    func fetchTodos() async throws -> [TodoDTO]
}

final class TodoAPIClient: TodoAPIClientProtocol {
    private let session: URLSession
    private let queue: DispatchQueue
    private let baseURL = URL(string: "https://dummyjson.com/todos")!
    
    init(session: URLSession = .shared, queue: DispatchQueue = DispatchQueue(label: "com.todo.api", qos: .userInitiated)) {
        self.session = session
        self.queue = queue
    }
    
    func fetchTodos() async throws -> [TodoDTO] {
        try await withCheckedThrowingContinuation { continuation in
            queue.async { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: NSError(domain: "TodoAPIClient", code: -1))
                    return
                }
                let task = self.session.dataTask(with: URLRequest(url: self.baseURL)) { data, response, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                        continuation.resume(throwing: NSError(domain: "TodoAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Bad response"]))
                        return
                    }
                    guard let data = data else {
                        continuation.resume(throwing: NSError(domain: "TodoAPI", code: -2))
                        return
                    }
                    do {
                        let decoded = try JSONDecoder().decode(TodosResponse.self, from: data)
                        continuation.resume(returning: decoded.todos)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
                task.resume()
            }
        }
    }
}
