import SwiftUI

struct TodoRowView: View {
    let item: TodoItem
    let onToggle: () -> Void
    let onDelete: () -> Void
    let onShare: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
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
            .alignmentGuide(.firstTextBaseline) { d in
                d[.firstTextBaseline]
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .strikethrough(item.completed)
                
                Text(item.description.isEmpty ? "Без описания" : item.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(DateFormatter.ddMMyy.string(from: item.createdAt))
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
        .contextMenu {
            Button {
                onEdit()
            } label: {
                Label("Редактировать", systemImage: "pencil")
            }
            
            Button {
                onShare()
            } label: {
                Label("Поделиться", systemImage: "square.and.arrow.up")
            }
            
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Удалить", systemImage: "trash")
            }
        }
    }
}

extension DateFormatter {
    static let ddMMyy: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter
    }()
}
