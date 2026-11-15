import SwiftUI

/// Modal opened from the NO ADS badge on Home or Shop.
struct NoAdsOfferModalView: View {
    @EnvironmentObject var store: GameStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
                .onTapGesture { dismiss() }

            VStack(spacing: 16) {
                HStack {
                    Spacer()
                    Button {
                        SoundHapticsManager.shared.playTap()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                    }
                }

                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 84, height: 84)
                        .overlay(Circle().stroke(Color(hex: "EF4444"), lineWidth: 5))
                    Text("AD")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .foregroundColor(Color(hex: "0F172A"))
                    Rectangle()
                        .fill(Color(hex: "EF4444"))
                        .frame(width: 72, height: 6)
                        .rotationEffect(.degrees(-45))
                }

                Text("NO ADS BUNDLE")
                    .font(.system(size: 23, weight: .black, design: .rounded))
                    .foregroundColor(.white)

                Text("Remove interstitial ads permanently and receive +50 Bonus Gems immediately.")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.92))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)

                Button {
                    store.activateNoAdsDemo()
                    dismiss()
                } label: {
                    Text(store.state.hasNoAds ? "ALREADY ACTIVE" : "ACTIVATE ($2.99)")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(store.state.hasNoAds ? Color(hex: "64748B") : Color(hex: "22C55E"))
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white, lineWidth: 2))
                }
                .disabled(store.state.hasNoAds)
                .buttonStyle(BouncyButtonStyle())
            }
            .padding(22)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "36B9FF"), Color(hex: "0C74DA")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.white, lineWidth: 3))
            )
            .padding(.horizontal, 26)
        }
    }
}
