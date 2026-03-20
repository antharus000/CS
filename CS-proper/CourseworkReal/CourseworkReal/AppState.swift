import Foundation
import Combine

class AppState: ObservableObject {
    @Published var userRole: String? = nil
}
