//
//  BookingFlowView.swift
//  RG10
//
//  Created by Moneeb Sayed on 9/17/25.
//

import SwiftUI
import StripePaymentSheet

struct BookingFlowView: View {
    @StateObject private var viewModel = BookingFlowViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Content
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.coordinator.isWebViewDismissing {
                    // Show loading while WebView is dismissing
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .red))
                            .scaleEffect(1.5)
                        
                        Text("Processing booking...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    bookingFormView
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $viewModel.showingWebView) {
            if let config = viewModel.coordinator.currentConfig {
                BookingWebView(
                    config: WebViewConfig(from: config),
                    onSuccessUrlDetected: { queryParams in
                        viewModel.handleSuccessUrlDetected(queryParams)
                    },
                    onDismiss: {
                        viewModel.dismissWebView()
                    }
                )
            } else {
                EmptyView()
            }
        }
        .onChange(of: viewModel.coordinator.isWebViewDismissing) { isDismissing in
            if isDismissing {
                // Automatically dismiss the WebView when transitioning to dismissing state
                viewModel.showingWebView = false
            }
        }
        .paymentSheet(
            isPresented: $viewModel.showingPaymentSheet,
            paymentSheet: viewModel.coordinator.currentPaymentSheet ?? PaymentSheet(paymentIntentClientSecret: "", configuration: PaymentSheet.Configuration()),
            onCompletion: { result in
                switch result {
                case .completed:
                    viewModel.handlePaymentCompleted()
                case .canceled:
                    viewModel.handlePaymentCancelled()
                case .failed(let error):
                    viewModel.handlePaymentFailed(error.localizedDescription)
                }
            }
        )
        .alert("Booking Successful!", isPresented: $viewModel.showingSuccessDialog) {
            Button("OK") {
                viewModel.dismissSuccessDialog()
                dismiss()
            }
        } message: {
            Text("Your training session has been booked successfully!")
        }
        .alert("Booking Error", isPresented: $viewModel.showingErrorDialog) {
            Button("Retry") {
                viewModel.retry()
            }
            Button("Cancel", role: .cancel) {
                viewModel.dismissErrorDialog()
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Book Training")
                    .font(.system(size: 32, weight: .bold))
                
                Text("Schedule your training session")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text(viewModel.loadingMessage)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Booking Form View
    
    private var bookingFormView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Session Type Selection
                sessionTypeSection
                
                // Coach Selection
                coachSelectionSection
                
                // Book Button
                bookButton
                
                Spacer(minLength: 50)
            }
            .padding()
        }
    }
    
    // MARK: - Session Type Section
    
    private var sessionTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Session Type")
                .font(.system(size: 18, weight: .semibold))
            
            VStack(spacing: 8) {
                ForEach(viewModel.sessionTypeOptions, id: \.self) { type in
                    sessionTypeRow(type: type)
                }
            }
            
            // Show group size options if group session is selected
            if viewModel.sessionType == .group {
                groupSizeSection
            }
        }
    }
    
    // MARK: - Group Size Section
    
    private var groupSizeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Group Size")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
            
            VStack(spacing: 6) {
                ForEach(viewModel.groupConfigs, id: \.id) { config in
                    groupSizeRow(config: config)
                }
            }
        }
        .padding(.leading, 16)
    }
    
    private func sessionTypeRow(type: BookingSessionType) -> some View {
        Button(action: {
            viewModel.selectSessionType(type)
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(type == .single ? "Single Session" : "Group Session")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(type == .single ? "1-on-1 training session" : "Group training session")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if viewModel.sessionType == type {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColors.primary)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func groupSizeRow(config: BookingConfig) -> some View {
        Button(action: {
            viewModel.selectGroupConfig(config)
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(config.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text("Minimum \(config.minAttendees) attendees")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if viewModel.selectedGroupConfig?.id == config.id {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColors.primary)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Coach Selection Section
    
    private var coachSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Coach")
                .font(.system(size: 18, weight: .semibold))
            
            if viewModel.coaches.isEmpty {
                Text("Loading coaches...")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                VStack(spacing: 8) {
                    ForEach(viewModel.coaches, id: \.name) { coach in
                        coachRow(coach: coach)
                    }
                }
            }
        }
    }
    
    private func coachRow(coach: Coach) -> some View {
        Button(action: {
            viewModel.selectCoach(coach)
        }) {
            HStack(spacing: 12) {
                // Coach Image
                AsyncImage(url: URL(string: coach.imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(coach.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(coach.role)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if viewModel.selectedCoach?.name == coach.name {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColors.primary)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Book Button
    
    private var bookButton: some View {
        Button(action: {
            viewModel.startBooking()
        }) {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "calendar.badge.plus")
                }
                
                Text("Schedule with Coach")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(viewModel.canStartBooking ? AppColors.primary : Color.gray)
            .cornerRadius(12)
        }
        .disabled(!viewModel.canStartBooking)
    }
    
}

// MARK: - Preview

struct BookingFlowView_Previews: PreviewProvider {
    static var previews: some View {
        BookingFlowView()
    }
}
