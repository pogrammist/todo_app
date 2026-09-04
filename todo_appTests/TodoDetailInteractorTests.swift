import XCTest
@testable import todo_app

final class TodoDetailInteractorTests: XCTestCase {
    private var interactor: TodoDetailInteractor!
    private var storage: MockTodoStorage!
    
    override func setUp() {
        super.setUp()
        storage = MockTodoStorage()
        interactor = TodoDetailInteractor(storage: storage)
    }
    
    func test_saveItem_createsNewItem() async throws {
        let newItem = TodoItem(id: 1, title: "New", description: "Desc", createdAt: Date(), updatedAt: nil, completed: false)
        
        let saved = try await interactor.saveItem(newItem)
        XCTAssertEqual(saved.title, "New")
        XCTAssertEqual(saved.description, "Desc")
        XCTAssertFalse(saved.completed)
        XCTAssertEqual(storage.storedItems.count, 1)
    }
    
    func test_saveItem_updatesExistingItem() async throws {
        let existingItem = TodoItem(id: 1, title: "Old", description: "Old desc", createdAt: Date(), updatedAt: nil, completed: false)
        storage.storedItems = [existingItem]
        
        let updated = TodoItem(id: 1, title: "New", description: "New desc", createdAt: existingItem.createdAt, updatedAt: Date(), completed: true)
        let saved = try await interactor.saveItem(updated)
        
        XCTAssertEqual(saved.title, "New")
        XCTAssertEqual(saved.description, "New desc")
        XCTAssertTrue(saved.completed)
        XCTAssertEqual(storage.storedItems.count, 1)
    }
    
    func test_loadItem_existingItem() async throws {
        let item = TodoItem(id: 1, title: "Test", description: "", createdAt: Date(), updatedAt: nil, completed: false)
        storage.storedItems = [item]
        
        let loaded = try await interactor.loadItem(id: 1)
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.title, "Test")
    }
    
    func test_loadItem_nonExistingItem_returnsNil() async throws {
        let loaded = try await interactor.loadItem(id: 999)
        XCTAssertNil(loaded)
    }
}
