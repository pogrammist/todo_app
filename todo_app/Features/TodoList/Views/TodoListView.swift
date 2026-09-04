import SwiftUI

struct TodoListView: View {
    @StateObject private var viewModel: TodoListViewModel
    @State private var searchText = ""
    
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
            .listStyle(.plain)
            .navigationTitle("Задачи")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Поиск задач")
            .onChange(of: searchText) { _, newValue in
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
