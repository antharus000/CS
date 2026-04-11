import Foundation
import Combine


class AppState: ObservableObject {
    // nil         not logged in , show AuthView
    // "customer"  show CustomerView
    // "admin"     show AdminView
    @Published var userRole: String? = nil
}
