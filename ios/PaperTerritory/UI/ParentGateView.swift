import SwiftUI

/// Kid-safe Parent Gate shown before any real-money StoreKit 2 purchase.
struct ParentGateView: View {
    let offerTitle: String
    let offerPrice: String
    let onApproved: () -> Void
    let onCancel: () -> Void

    @State private var lhs: Int = Int.random(in: 4...9)
    @State private var rhs: Int = Int.random(in: 3...8)
    @State private var answerText: String = ""
    @State private var showError = false

    private var expectedAnswer: Int {
        lhs * rhs
    }

    var body: some View {
        ZStack {
            Color(hex: 0x09_0E_1F).ignoresSafeArea()
            gateCard
        }
    }

    private var gateCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 40))
                .foregroundColor(Color(hex: 0x38_BD_F8))

            Text("Ask a Parent")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundColor(.white)

            Text("Confirm purchase of \(offerTitle) (\(offerPrice)) by solving:")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)

            Text("What is \(lhs) x \(rhs)?")
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundColor(Color(hex: 0xFA_CC_15))

            TextField("Enter answer", text: $answerText)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                .foregroundColor(Color(hex: 0x0F_17_2A))
                .frame(maxWidth: 160)

            if showError {
                Text("Incorrect answer. Try again.")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: 0xFB_71_85))
            }

            HStack(spacing: 12) {
                Button("Cancel", action: onCancel)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(Color.white.opacity(0.2)))

                Button("Continue", action: verify)
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(Color(hex: 0x22_C5_5E)))
            }
        }
        .padding(24)
        .background(RoundedRectangle(cornerRadius: 24).fill(Color(hex: 0x0F_17_2A)))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.4), lineWidth: 2))
        .padding(24)
    }

    private func verify() {
        let trimmed = answerText.trimmingCharacters(in: .whitespacesAndNewlines)
        if Int(trimmed) == expectedAnswer {
            showError = false
            onApproved()
        } else {
            showError = true
            lhs = Int.random(in: 4...9)
            rhs = Int.random(in: 3...8)
            answerText = ""
        }
    }
}
