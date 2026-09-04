import SwiftUI

struct TodoListView: View {
    @StateObject private var viewModel: TodoListViewModel
    
    init(viewModel: TodoListViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            List {
                ForEach(viewModel.items) { item in
                    TodoRowView(
                        item: item,
                        onToggle: { viewModel.didToggle(item) },
                        onDelete: { viewModel.didTapDelete(item) }
                    )
                }
            }
            .navigationTitle("Задачи")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.didTapAdd()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .searchable(text: .constant(""), prompt: "Поиск задач")
            .onChange(of: "", initial: false) { _, newValue in
                viewModel.didSearch(query: newValue)
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .alert("Ошибка", isPresented: .constant(viewModel.errorMessage != nil), presenting: viewModel.errorMessage) { _ in
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: { error in
                Text(error)
            }
            .navigationDestination(for: TodoListRoute.self) { route in
                switch route {
                case .add:
                    TodoDetailView(
                        viewModel: TodoDetailViewModel(
                            interactor: TodoDetailInteractor(),
                            router: TodoDetailRouter()
                        )
                    )
                case .edit(let item):
                    TodoDetailView(
                        viewModel: TodoDetailViewModel(
                            interactor: TodoDetailInteractor(),
                            router: TodoDetailRouter(),
                            item: item
                        )
                    )
                }
            }
        }
        .onAppear {
            viewModel.viewDidLoad()
        }
    }
}
