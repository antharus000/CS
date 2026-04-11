import SwiftUI

// forces light mode for the whole app.
// .preferredColorScheme(.light) is set here at the root so it only needs
// to appear once rather than on every view.
struct ContentView: View {
    var body: some View {
        Initial()
            .preferredColorScheme(.light)
    }
}
