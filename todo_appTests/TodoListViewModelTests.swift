import XCTest
@testable import todo_app

final class TodoListViewModelTests: XCTestCase {
    private var viewModel: TodoListViewModel!
    private var mockStorage: MockTodoStorage!
    private var mockRouter: MockTodoListRouter!
    private var mockAPI: MockTodoAPIClient!
    
    override func setUp() {
        super.setUp()
        mockStorage = MockTodoStorage()
        mockAPI = MockTodoAPIClient()
        mockRouter = MockTodoListRouter()
        viewModel = TodoListViewModel(
            interactor: TodoListInteractor(storage: mockStorage, api: mockAPI),
            router: mockRouter
        )
    }
    
    func test_viewDidLoad_loadsItems() async throws {
        mockStorage.storedItems = [
            TodoItem(id: 1, title: "Test", description: "", createdAt: Date(), updatedAt: nil, completed: false)
        ]
        
        viewModel.viewDidLoad()
        try await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertEqual(viewModel.items.count, 1)
        XCTAssertEqual(viewModel.items.first?.title, "Test")
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func test_didTapAdd_callsRouter() {
        viewModel.didTapAdd()
        XCTAssertTrue(mockRouter.navigateToAddCalled)
    }
    
    func test_didTapEdit_callsRouter() {
        let item = TodoItem(id: 1, title: "Edit", description: "", createdAt: Date(), updatedAt: nil, completed: false)
        viewModel.didTapEdit(item)
        XCTAssertTrue(mockRouter.navigateToEditCalled)
        XCTAssertEqual(mockRouter.editedItem?.id, item.id)
    }
    
    func test_didSearch_withEmptyQuery_loadsAll() async throws {
        mockStorage.storedItems = [
            TodoItem(id: 1, title: "A", description: "", createdAt: Date(), updatedAt: nil, completed: false)
        ]
        
        viewModel.didSearch(query: "")
        try await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertEqual(viewModel.items.count, 1)
    }
    
    func test_didSearch_withQuery_filtersItems() async throws {
        mockStorage.storedItems = [
            TodoItem(id: 1, title: "alpha", description: "", createdAt: Date(), updatedAt: nil, completed: false),
            TodoItem(id: 2, title: "beta", description: "gamma", createdAt: Date(), updatedAt: nil, completed: false)
        ]
        
        viewModel.didSearch(query: "gamma")
        try await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertEqual(viewModel.items.count, 1)
        XCTAssertEqual(viewModel.items.first?.title, "beta")
    }
}
