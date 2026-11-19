import SwiftUI

/// Daily Missions screen showing 3 random missions per day and the Daily Mission Chest.
struct MissionsView: View {
    @ObservedObject var store: PlayerProfileStore

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                dailyChestCard
                missionsHeader
                ForEach(store.profile.dailyMissions.missions) { mission in
                    missionRow(mission)
                }
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 24)
        }
    }

    private var dailyChestCard: some View {
        let state = store.profile.dailyMissions
        return VStack(spacing: 12) {
            HStack(spacing: 14) {
                Image(systemName: "gift.fill")
                    .font(.system(size: 36))
                    .foregroundColor(Color(hex: 0xFA_CC_15))
                    .frame(width: 60, height: 60)
                    .background(Circle().fill(Color.white.opacity(0.15)))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily Mission Chest")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text("1% Skin chance or random Gold & Diamonds (up to 1,000 each)")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                }
            }

            HStack {
                Text("Progress: \(state.completedCount)/\(GameConfig.dailyMissionCount) missions")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: 0xFA_CC_15))
                Spacer()
                Button {
                    _ = store.claimDailyMissionChest()
                } label: {
                    let bgColor = state.canClaimChest ? Color(hex: 0x22_C5_5E) : Color.gray.opacity(0.45)
                    Text(chestButtonTitle(state))
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 9)
                        .background(Capsule().fill(bgColor))
                }
                .disabled(!state.canClaimChest)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: 0x4F_46_E5), Color(hex: 0x1E_3A_8A)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(state.canClaimChest ? Color(hex: 0xFA_CC_15) : Color.white.opacity(0.35), lineWidth: 2)
        )
    }

    private var missionsHeader: some View {
        HStack {
            Text("Today's Missions (\(store.profile.dailyMissions.dayKey))")
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Spacer()
        }
    }

    private func missionRow(_ mission: DailyMission) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(mission.title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
                if mission.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: 0x22_C5_5E))
                } else {
                    Text("\(mission.progress)/\(mission.target)")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundColor(Color(hex: 0x38_BD_F8))
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.16))
                    Capsule()
                        .fill(mission.isCompleted ? Color(hex: 0x22_C5_5E) : Color(hex: 0x38_BD_F8))
                        .frame(width: max(8, geo.size.width * CGFloat(mission.fraction)))
                }
            }
            .frame(height: 10)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.12)))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(mission.isCompleted ? Color(hex: 0x22_C5_5E) : Color.white.opacity(0.22), lineWidth: 1.5)
        )
    }

    private func chestButtonTitle(_ state: DailyMissionState) -> String {
        if state.chestClaimed {
            return "Claimed"
        }
        return state.canClaimChest ? "Open Chest" : "Locked"
    }
}
