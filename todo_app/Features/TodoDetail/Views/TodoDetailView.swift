import SwiftUI

struct TodoDetailView: View {
    @StateObject private var viewModel: TodoDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(viewModel: TodoDetailViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Основное") {
                    TextField("Название", text: $viewModel.title)
                    TextEditor(text: $viewModel.description)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle(viewModel.isEditing ? "Редактирование" : "Новая задача")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        viewModel.save()
                        dismiss()
                    }
                    .disabled(viewModel.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear {
            viewModel.viewDidLoad()
        }
    }
}
