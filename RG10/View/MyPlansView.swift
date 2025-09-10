//
//  MyPlansView.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/9/25.
//

import SwiftUI
import Combine
// MARK: - Models
struct TrainingPlan: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let progress: Double
    let weeklySessions: [TrainingSession]
}

struct TrainingSession: Identifiable {
    let id = UUID()
    let day: String
    let time: String
    let type: String
    let duration: String
}

// MARK: - View Model
class TrainingPlansViewModel: ObservableObject {
    @Published var currentPlan: TrainingPlan?
    
    init() {
        // Mock data - replace with actual data fetching
        loadCurrentPlan()
    }
    
    private func loadCurrentPlan() {
        // This would normally fetch from your backend
        currentPlan = TrainingPlan(
            name: "Elite Performance Plan",
            description: "Advanced training program for competitive players",
            progress: 0.65,
            weeklySessions: [
                TrainingSession(day: "Monday", time: "4:00 PM", type: "Technical Skills", duration: "90 min"),
                TrainingSession(day: "Wednesday", time: "4:00 PM", type: "Tactical Training", duration: "90 min"),
                TrainingSession(day: "Friday", time: "4:00 PM", type: "Match Preparation", duration: "90 min")
            ]
        )
    }
}

// MARK: - Main View
struct MyPlansView: View {
    @StateObject private var viewModel = TrainingPlansViewModel()
    
    var body: some View {
        ScrollView {
            if let plan = viewModel.currentPlan {
                VStack(alignment: .leading, spacing: 20) {
                    // Plan Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(plan.name)
                            .font(.system(size: 28, weight: .bold))
                        Text(plan.description)
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .padding()
                    
                    // Progress
                    ProgressSection(progress: plan.progress)
                    
                    // Weekly Schedule
                    WeeklyScheduleSection(sessions: plan.weeklySessions)
                }
            } else {
                EmptyStateView(
                    icon: "doc.text",
                    title: "No Active Plan",
                    message: "You don't have an active training plan"
                )
                .frame(minHeight: 400)
            }
        }
        .navigationTitle("My Training Plan")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
}

// MARK: - Progress Section Component
struct ProgressSection: View {
    let progress: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progress")
                .font(.system(size: 20, weight: .bold))
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(AppConstants.Colors.primaryRed)
                    
                    Spacer()
                    
                    Text("Completed")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(AppConstants.Colors.primaryRed)
                            .frame(width: geometry.size.width * progress, height: 8)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.08), radius: 4)
        }
        .padding(.horizontal)
    }
}

// MARK: - Weekly Schedule Section Component
struct WeeklyScheduleSection: View {
    let sessions: [TrainingSession]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Schedule")
                .font(.system(size: 20, weight: .bold))
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                ForEach(sessions) { session in
                    SessionCard(session: session)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct SessionCard: View {
    let session: TrainingSession
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.day)
                    .font(.system(size: 16, weight: .semibold))
                Text(session.time)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(session.type)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppConstants.Colors.primaryRed)
                Text(session.duration)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 4)
    }
}

// MARK: - Empty State View Component
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.black)
            
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}
