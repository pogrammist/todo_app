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
                        TextField("Название задачи", text: $viewModel.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top, 20)
                            .textInputAutocapitalization(.sentences)
                            .disableAutocorrection(false)
                        
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
                    Button {
                        viewModel.cancel()
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Назад")
                        }
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
        .onDisappear {
            let trimmedTitle = viewModel.title.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedTitle.isEmpty {
                viewModel.save()
            }
        }
        .tint(.yellow)
    }
}
