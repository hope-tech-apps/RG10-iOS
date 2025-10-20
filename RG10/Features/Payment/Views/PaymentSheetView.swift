//
//  PaymentSheetView.swift
//  RG10
//
//  Created by Moneeb Sayed on 1/17/25.
//

import SwiftUI
import StripePaymentSheet

// MARK: - Payment Sheet View (SwiftUI Native)

struct PaymentSheetView: View {
    let paymentData: PaymentSheetData
    let onResult: @MainActor (PaymentSheetResult) -> Void
    
    @State private var paymentSheet: PaymentSheet?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    
                    Text("Preparing payment...")
                        .foregroundColor(.white)
                        .font(.headline)
                } else if let error = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        
                        Text("Payment Error")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text(error)
                            .font(.body)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Button("Close") {
                            onResult(.failed(error: PaymentError.paymentFailed(error)))
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            preparePaymentSheet()
        }
        .paymentSheet(
            isPresented: .constant(paymentSheet != nil),
            paymentSheet: paymentSheet ?? PaymentSheet(paymentIntentClientSecret: "", configuration: PaymentSheet.Configuration()),
            onCompletion: { result in
                onResult(result)
            }
        )
    }
    
    @MainActor
    private func preparePaymentSheet() {
        Task {
            do {
                let sheet = try await PaymentSheetService.shared.createSubscriptionPaymentSheet(with: paymentData)
                self.paymentSheet = sheet
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}

// MARK: - Payment Sheet Host

struct PaymentSheetHost: View {
    let paymentData: PaymentSheetData
    let onResult: @MainActor (PaymentSheetResult) -> Void
    
    @State private var showingPaymentSheet = false
    
    var body: some View {
        Color.clear
            .onAppear {
                showingPaymentSheet = true
            }
            .sheet(isPresented: $showingPaymentSheet) {
                PaymentSheetView(
                    paymentData: paymentData,
                    onResult: { result in
                        onResult(result)
                        showingPaymentSheet = false
                    }
                )
            }
    }
}

// MARK: - Payment Flow View

struct PaymentFlowView: View {
    @StateObject private var subscriptionViewModel = SubscriptionFlowViewModel()
    @StateObject private var bookingViewModel = BookingFlowViewModel()
    
    let flowType: PaymentFlowType
    let priceId: String?
    let planName: String?
    let bookingUid: String?
    let onCompletion: @MainActor (PaymentSheetResult) -> Void
    
    enum PaymentFlowType {
        case subscription
        case booking
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                Text(loadingMessage)
                    .foregroundColor(.white)
                    .font(.headline)
                    .multilineTextAlignment(.center)
            }
        }
        .onAppear {
            startPaymentFlow()
        }
        .onChange(of: currentState) { state in
            handleStateChange(state)
        }
    }
    
    // MARK: - Computed Properties
    
    private var currentState: BookingState {
        // TODO: Update to work with new BookingFlowViewModel
        return .idle
    }
    
    private var loadingMessage: String {
        switch currentState {
        case .processing(let message):
            return message
        case .paymentSheetReady:
            return "Opening payment..."
        default:
            return "Preparing payment..."
        }
    }
    
    // MARK: - Methods
    
    private func startPaymentFlow() {
        Task {
            switch flowType {
            case .subscription:
                // Subscription flow is handled by dedicated subscription views
                onCompletion(.failed(error: PaymentError.invalidConfiguration))
                
            case .booking:
                guard let bookingUid = bookingUid else {
                    onCompletion(.failed(error: PaymentError.invalidConfiguration))
                    return
                }
                // TODO: Update to work with new BookingFlowViewModel
                // await bookingViewModel.startBookingPayment(bookingUid: bookingUid)
                break
            }
        }
    }
    
    private func handleStateChange(_ state: BookingState) {
        switch state {
        case .paymentSheetReady(let paymentData):
            // Present payment sheet
            break
            
        case .completed(let message):
            onCompletion(.completed)
            
        case .cancelled(let message):
            onCompletion(.canceled)
            
        case .error(let message):
            onCompletion(.failed(error: PaymentError.paymentFailed(message)))
            
        case .idle, .processing:
            // Continue showing loading
            break
        }
    }
}

// MARK: - Payment Result Handler

struct PaymentResultHandler: View {
    let result: PaymentSheetResult
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: resultIcon)
                .font(.system(size: 60))
                .foregroundColor(resultColor)
            
            Text(resultTitle)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(resultMessage)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Done") {
                onDismiss()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
    
    private var resultIcon: String {
        switch result {
        case .completed:
            return "checkmark.circle.fill"
        case .canceled:
            return "xmark.circle.fill"
        case .failed:
            return "exclamationmark.triangle.fill"
        }
    }
    
    private var resultColor: Color {
        switch result {
        case .completed:
            return .green
        case .canceled:
            return .orange
        case .failed:
            return .red
        }
    }
    
    private var resultTitle: String {
        switch result {
        case .completed:
            return "Payment Successful"
        case .canceled:
            return "Payment Cancelled"
        case .failed:
            return "Payment Failed"
        }
    }
    
    private var resultMessage: String {
        switch result {
        case .completed:
            return "Your payment has been processed successfully."
        case .canceled:
            return "You cancelled the payment process."
        case .failed(let error):
            return error.localizedDescription
        }
    }
}

// MARK: - Preview

#Preview {
    PaymentResultHandler(
        result: .completed,
        onDismiss: {}
    )
}
