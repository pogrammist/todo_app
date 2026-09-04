import SwiftUI

struct TodoRowView: View {
    let item: TodoItem
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            ZStack {
                Image(systemName: "circle")
                    .foregroundColor(item.completed ? .yellow : .gray)
                    .font(.system(size: 24, weight: .thin))
                
                if item.completed {
                    Image(systemName: "checkmark")
                        .foregroundColor(.yellow)
                        .font(.system(size: 16, weight: .light))
                }
            }
            .onTapGesture {
                onToggle()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .strikethrough(item.completed)
                
                if !item.description.isEmpty {
                    Text(item.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text(item.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Удалить", systemImage: "trash")
            }
        }
    }
}
