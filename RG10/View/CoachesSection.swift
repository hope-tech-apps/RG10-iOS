// MARK: - Coaches Section
struct CoachesSection: View {
    let coaches: [Coach]
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Meet the Coaches")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(coaches) { coach in
                        CoachCard(coach: coach) {
                            coordinator.showStaff()
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}
