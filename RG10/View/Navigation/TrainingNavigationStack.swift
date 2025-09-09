//
//  TrainingNavigationStack.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/8/25.
//

import SwiftUI

struct TrainingNavigationStack: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @StateObject private var viewModel = TrainingViewModel()
    
    var body: some View {
        NavigationStack(path: $navigationManager.trainingPath) {
            TrainingTabView()
                .environmentObject(viewModel)
                .navigationDestination(for: NavigationDestination.self) { destination in
                    destinationView(for: destination)
                }
        }
    }
    
    @ViewBuilder
    private func destinationView(for destination: NavigationDestination) -> some View {
        switch destination {
        case .trainingPackages:
            TrainingPackagesView()
        case .campDetail(let camp):
            CampDetailView(camp: camp)
        case .workoutDetail(let workoutId):
            WorkoutDetailView(workoutId: workoutId)
        default:
            EmptyView()
        }
    }
}

// Camp Detail View
struct CampDetailView: View {
    let camp: CampData
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Camp image
                Image(camp.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(camp.title)
                        .font(.system(size: 28, weight: .bold))
                    
                    Label(camp.dates, systemImage: "calendar")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    
                    Text("Join us for an intensive soccer training camp designed to elevate your skills to the next level.")
                        .font(.system(size: 16))
                        .lineSpacing(4)
                    
                    // Registration button
                    Button(action: {}) {
                        Text("Register Now")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppConstants.Colors.primaryRed)
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Camp Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct WorkoutDetailView: View {
    let workoutId: String
    
    var body: some View {
        VStack {
            Text("Workout Detail")
                .font(.title)
            Text("ID: \(workoutId)")
        }
        .navigationTitle("Workout")
        .navigationBarTitleDisplayMode(.inline)
    }
}
