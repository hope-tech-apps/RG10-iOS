// MARK: - Placeholder Tab Views
struct TrainingTabView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Training")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.gray)
            Text("Coming Soon")
                .font(.system(size: 16))
                .foregroundColor(.gray.opacity(0.6))
            Spacer()
        }
    }
}
