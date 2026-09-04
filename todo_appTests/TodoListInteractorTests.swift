import XCTest
@testable import todo_app

final class TodoListInteractorTests: XCTestCase {
    private var interactor: TodoListInteractor!
    private var storage: MockTodoStorage!
    private var api: MockTodoAPIClient!
    
    override func setUp() {
        super.setUp()
        storage = MockTodoStorage()
        api = MockTodoAPIClient()
        interactor = TodoListInteractor(storage: storage, api: api)
    }
    
    func test_loadTodos_whenStorageEmpty_callsAPI() async throws {
        api.result = .success([
            TodoDTO(id: 1, todo: "API item", completed: false, userId: 1)
        ])
        
        let items = try await interactor.loadTodos()
        XCTAssertFalse(items.isEmpty)
        XCTAssertEqual(items.first?.title, "API item")
    }
    
    func test_loadTodos_whenStorageHasData_returnsStoredItems() async throws {
        storage.storedItems = [
            TodoItem(id: 1, title: "Stored", description: "", createdAt: Date(), updatedAt: nil, completed: false)
        ]
        
        let items = try await interactor.loadTodos()
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.title, "Stored")
    }
    
    func test_searchTodos_returnsFiltered() async throws {
        storage.storedItems = [
            TodoItem(id: 1, title: "alpha", description: "", createdAt: Date(), updatedAt: nil, completed: false),
            TodoItem(id: 2, title: "beta", description: "gamma", createdAt: Date(), updatedAt: nil, completed: false)
        ]
        
        let items = try await interactor.searchTodos(query: "gamma")
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.title, "beta")
    }
    
    func test_toggleTodo_updatesItem() async throws {
        storage.storedItems = [
            TodoItem(id: 1, title: "Task", description: "", createdAt: Date(), updatedAt: nil, completed: false)
        ]
        
        let updated = try await interactor.toggleTodo(storage.storedItems[0])
        XCTAssertTrue(updated.completed)
        XCTAssertEqual(updated.title, "Task")
    }
    
    func test_deleteTodo_removesItem() async throws {
        storage.storedItems = [
            TodoItem(id: 1, title: "A", description: "", createdAt: Date(), updatedAt: nil, completed: false)
        ]
        
        try await interactor.deleteTodo(storage.storedItems[0])
        XCTAssertTrue(storage.storedItems.isEmpty)
    }
}
