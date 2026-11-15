import SwiftUI

/// Main Home lobby screen faithfully replicating the video layout (00:50).
struct HomeView: View {
    @EnvironmentObject var store: GameStore

    var body: some View {
        ZStack {
            PaperBackgroundView()

            VStack(spacing: 0) {
                TopResourceBar(showHomeControls: true)

                // Right-side floating Offer & No-Ads stack + Center Mode/Country badge
                ZStack(alignment: .topTrailing) {
                    // Center target Country / Mode progress pill
                    VStack(spacing: 6) {
                        modeProgressBanner
                            .padding(.top, 20)
                    }
                    .frame(maxWidth: .infinity)

                    // Right action pills matching 00:50
                    VStack(spacing: 12) {
                        dailyGiftSideButton
                        if !store.state.hasNoAds {
                            noAdsSideButton
                        }
                    }
                    .padding(.trailing, 14)
                    .padding(.top, 14)
                }

                // 3D Character on floating territory island (tapping opens Skin Showcase)
                ZStack {
                    Skin3DPreviewView(
                        skin: store.equippedSkin,
                        showTerritoryIsland: true,
                        interactiveRotate: false
                    )
                    .frame(maxWidth: .infinity, maxHeight: 330)

                    // Subtle tap target hint
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            store.openShowcase(skinId: store.equippedSkin.id)
                        }
                }
                .padding(.top, -10)

                Spacer(minLength: 4)

                // Bottom action row: [MODES]  [Start x5 + PLAY]  [PROFILE]
                HStack(alignment: .bottom, spacing: 14) {
                    modesLeftButton

                    VStack(spacing: 10) {
                        startFiveXButton
                        bigPlayButton
                    }

                    profileRightButton
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 102)
            }
        }
    }

    // MARK: - Subviews

    private var modeProgressBanner: some View {
        Button {
            SoundHapticsManager.shared.playTap()
            if store.state.activeMode == .worldConquest {
                withAnimation { store.selectedTab = .world }
            } else {
                store.showModesModal = true
            }
        } label: {
            VStack(spacing: 4) {
                if store.state.activeMode == .worldConquest {
                    let country = store.selectedCountry
                    let pct = store.selectedCountryProgress
                    Text(country.name)
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.35), radius: 2, y: 1)

                    ZStack {
                        Capsule()
                            .fill(Color(hex: "0C234B").opacity(0.72))
                            .frame(width: 132, height: 22)
                            .overlay(Capsule().stroke(Color.white, lineWidth: 2))

                        GeometryReader { geo in
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "38BDF8"), Color(hex: "22C55E")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: max(12, geo.size.width * CGFloat(pct) / 100.0))
                        }
                        .frame(width: 126, height: 16)
                        .clipShape(Capsule())

                        Text("\(pct)%")
                            .font(.system(size: 12, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.45), radius: 1, y: 1)
                    }
                } else {
                    Text(store.state.activeMode.title)
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    HStack(spacing: 5) {
                        Image(systemName: store.state.activeMode.iconName)
                            .font(.system(size: 12, weight: .bold))
                        Text(store.state.activeMode.isSeasonal ? "Seasonal Event" : "Active Mode")
                            .font(.system(size: 12, weight: .black, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 5)
                    .background(
                        LinearGradient(
                            colors: store.state.activeMode.accentColors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.white, lineWidth: 2))
                }
            }
        }
        .buttonStyle(BouncyButtonStyle())
    }

    private var dailyGiftSideButton: some View {
        Button {
            SoundHapticsManager.shared.playTap()
            store.showDailyRewards = true
        } label: {
            VStack(spacing: 2) {
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(hex: "0C234B").opacity(0.65))
                        .frame(width: 52, height: 52)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.75), lineWidth: 2))
                        .overlay(
                            Image(systemName: "gift.fill")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(hex: "38BDF8"))
                        )

                    Circle()
                        .fill(Color(hex: "22C55E"))
                        .frame(width: 16, height: 16)
                        .overlay(Image(systemName: "clock.fill").font(.system(size: 9)).foregroundColor(.white))
                        .offset(x: 4, y: -4)
                }

                Text(store.formattedCountdown)
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(hex: "0C234B").opacity(0.7))
                    .clipShape(Capsule())
            }
        }
        .buttonStyle(BouncyButtonStyle())
    }

    private var noAdsSideButton: some View {
        Button {
            SoundHapticsManager.shared.playTap()
            store.showNoAdsModal = true
        } label: {
            VStack(spacing: 2) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 44, height: 44)
                        .overlay(Circle().stroke(Color(hex: "EF4444"), lineWidth: 3.5))
                    Text("AD")
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundColor(Color(hex: "0F172A"))
                    Rectangle()
                        .fill(Color(hex: "EF4444"))
                        .frame(width: 38, height: 3.5)
                        .rotationEffect(.degrees(-45))
                }
                Text("NO ADS")
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(hex: "0C234B").opacity(0.75))
                    .clipShape(Capsule())
            }
        }
        .buttonStyle(BouncyButtonStyle())
    }

    private var modesLeftButton: some View {
        Button {
            SoundHapticsManager.shared.playTap()
            store.showModesModal = true
        } label: {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: store.state.activeMode.iconName)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 42, height: 34)

                    Circle()
                        .fill(Color(hex: "EF4444"))
                        .frame(width: 10, height: 10)
                }
                Text("MODES")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }
            .frame(width: 84, height: 74)
            .background(
                LinearGradient(
                    colors: [Color(hex: "4F86C6"), Color(hex: "2D578F")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(18)
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white, lineWidth: 2.5))
            .shadow(color: Color.black.opacity(0.24), radius: 5, y: 4)
        }
        .buttonStyle(BouncyButtonStyle())
    }

    private var startFiveXButton: some View {
        Button {
            store.toggleStartFiveX()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: store.startFiveXActive ? "checkmark.circle.fill" : "play.rectangle.fill")
                    .font(.system(size: 16, weight: .bold))
                VStack(alignment: .leading, spacing: -1) {
                    Text("Start")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                    Text("x5 Larger")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(
                LinearGradient(
                    colors: store.startFiveXActive
                        ? [Color(hex: "F59E0B"), Color(hex: "D97706")]
                        : [Color(hex: "2CD46D"), Color(hex: "16A34A")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.white, lineWidth: 2.5))
            .shadow(color: Color.black.opacity(0.22), radius: 4, y: 3)
        }
        .buttonStyle(BouncyButtonStyle())
    }

    private var bigPlayButton: some View {
        Button {
            store.startMatch()
        } label: {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "FFF059"), Color(hex: "F5A800")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 88, height: 88)
                    .overlay(Circle().stroke(Color.white, lineWidth: 5))
                    .shadow(color: Color.black.opacity(0.28), radius: 7, y: 5)

                Image(systemName: "play.fill")
                    .font(.system(size: 38, weight: .black))
                    .foregroundColor(.white)
                    .offset(x: 3)
                    .shadow(color: Color(hex: "B45309").opacity(0.5), radius: 2, y: 2)
            }
        }
        .buttonStyle(BouncyButtonStyle())
    }

    private var profileRightButton: some View {
        Button {
            SoundHapticsManager.shared.playTap()
            store.showProfileModal = true
        } label: {
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(hex: "FB923C"))
                        .frame(width: 24, height: 24)
                        .overlay(
                            HStack(spacing: 3) {
                                Circle().fill(Color.white).frame(width: 5, height: 5)
                                Circle().fill(Color.white).frame(width: 5, height: 5)
                            }
                        )
                    VStack(alignment: .leading, spacing: 0) {
                        Text(store.state.playerName)
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 9))
                                .foregroundColor(Color(hex: "FDE047"))
                            Text("\(store.state.starScore)")
                                .font(.system(size: 11, weight: .black, design: .rounded))
                                .foregroundColor(Color(hex: "FEF08A"))
                        }
                    }
                }
                Text("PROFILE")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(.horizontal, 8)
            .frame(width: 92, height: 74)
            .background(
                LinearGradient(
                    colors: [Color(hex: "FF9924"), Color(hex: "EA580C")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(18)
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white, lineWidth: 2.5))
            .shadow(color: Color.black.opacity(0.24), radius: 5, y: 4)
        }
        .buttonStyle(BouncyButtonStyle())
    }
}
