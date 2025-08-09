import SwiftUI

struct BookTabView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Book")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.gray)
            Text("Coming Soon")
                .font(.system(size: 16))
                .foregroundColor(.gray.opacity(0.6))
            Spacer()
        }
    }
}
