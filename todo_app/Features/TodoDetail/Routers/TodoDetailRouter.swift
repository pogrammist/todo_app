import Foundation
import SwiftUI

final class TodoDetailRouter: TodoDetailRouterProtocol {
    func dismiss() {
        // Dismiss is handled by the view using @Environment(\.dismiss)
    }
}
