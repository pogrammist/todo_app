import SwiftUI

struct TodoListView: View {
    @StateObject private var viewModel: TodoListViewModel
    @State private var searchText = ""
    
    init(viewModel: TodoListViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            listContent
                .navigationTitle("Задачи")
                .navigationBarTitleDisplayMode(.large)
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Поиск задач")
                .onChange(of: searchText) { _, newValue in
                    viewModel.didSearch(query: newValue)
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
        .onChange(of: viewModel.newTaskItem) { _, newValue in
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
        .fullScreenCover(item: $viewModel.newTaskItem) { item in
            TodoDetailView(
                viewModel: TodoDetailViewModel(
                    interactor: TodoDetailInteractor(),
                    router: TodoDetailRouter(),
                    item: item
                )
            )
        }
        .safeAreaInset(edge: .bottom) {
            ZStack {
                Text("\(viewModel.items.count) \(taskCountLabel(viewModel.items.count))")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                HStack {
                    Spacer()
                    Button(action: { viewModel.didTapAdd() }) {
                        Image(systemName: "square.and.pencil")
                            .font(.title2)
                            .foregroundColor(.yellow)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
        }
    }
    
    @ViewBuilder
    private var listContent: some View {
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
        .padding(.bottom, 50)
    }
    
    func taskCountLabel(_ count: Int) -> String {
        let mod10 = count % 10
        let mod100 = count % 100
        
        if mod100 >= 11 && mod100 <= 19 {
            return "Задач"
        }
        
        switch mod10 {
        case 1:
            return "Задача"
        case 2...4:
            return "Задачи"
        default:
            return "Задач"
        }
    }
}

struct ShareSheetView: View {
    let item: TodoItem
    
    var body: some View {
        ShareLink(item: "\(item.title)\n\(item.description.isEmpty ? "Без описания" : item.description)", preview: SharePreview(item.title, image: Image(systemName: "checkmark.circle")))
    }
}

#Preview {
    TodoListView(
        viewModel: TodoListViewModel(
            interactor: TodoListInteractor(storage: TodoStorage(), api: TodoAPIClient()),
            router: TodoListRouter()
        )
    )
}
