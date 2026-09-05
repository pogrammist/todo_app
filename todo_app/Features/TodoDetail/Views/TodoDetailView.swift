import SwiftUI

struct TodoDetailView: View {
    @StateObject private var viewModel: TodoDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(viewModel: TodoDetailViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(viewModel.title.isEmpty ? "Без названия" : viewModel.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top, 20)
                        
                        if let item = viewModel.existingItem {
                            Text(DateFormatter.ddMMyy.string(from: item.createdAt))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        TextEditor(text: $viewModel.description)
                            .font(.body)
                            .foregroundColor(.white)
                            .background(Color.clear)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 200)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Назад") {
                        viewModel.cancel()
                        dismiss()
                    }
                    .foregroundColor(.yellow)
                }
            }
        }
        .onAppear {
            viewModel.viewDidLoad()
        }
        .onChange(of: viewModel.title) { _, _ in viewModel.scheduleSave() }
        .onChange(of: viewModel.description) { _, _ in viewModel.scheduleSave() }
        .tint(.yellow)
    }
}
