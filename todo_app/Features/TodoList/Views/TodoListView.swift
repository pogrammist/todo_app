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
                        onDelete: { viewModel.didTapDelete(item) },
                        onShare: { viewModel.didTapShare(item) },
                        onEdit: { viewModel.didTapEdit(item) }
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
        }
        .onAppear {
            viewModel.viewDidLoad()
        }
        .onChange(of: viewModel.editingItem) { _, newValue in
            if newValue == nil {
                viewModel.viewDidLoad()
            }
        }
        .onChange(of: viewModel.editingItem) { _, newValue in
            if newValue == nil {
                viewModel.viewDidLoad()
            }
        }
        .sheet(item: Binding(
            get: { viewModel.sharedItem },
            set: { _ in viewModel.sharedItem = nil }
        )) { item in
            ShareSheetView(item: item)
        }
        .fullScreenCover(item: $viewModel.editingItem) { item in
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

struct ShareSheetView: View {
    let item: TodoItem
    
    var body: some View {
        ShareLink(item: "\(item.title)\n\(item.description.isEmpty ? "Без описания" : item.description)", preview: SharePreview(item.title, image: "checkmark.circle"))
    }
}
