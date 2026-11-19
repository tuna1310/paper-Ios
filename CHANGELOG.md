# Changelog

All notable changes to **Paper Territory (iOS)** are documented in this file.

## [Unreleased]

### Added — Paper.io 2 Pure Native Upgrade (Ruleset, Economy, 10 Ranks, Daily Missions, 6x8 World Map, 4-Zone Shop & StoreKit 2)
- **Updated Paper.io 2 Gameplay Rules:** Crossing your own active trail is now non-lethal (`Entity.swift`); players are only eliminated when outside their own territory and struck on their exposed trail (plus safe-home defender immunity in head-on collisions in `CollisionDetector.swift`).
- **Dual Currencies & Match Rewards (`RankSystem.swift`):** Added Gold and Diamonds earned proportionally to territory percentage achieved in every match, plus kill, victory, first-country-clear, and rank multiplier bonuses.
- **10-Tier Rank Ladder (`RankSystem.swift`, `RankView.swift`):** Implemented `Bronze`, `Silver`, `Gold`, `Platinum`, `Diamond`, `Elite`, `Master`, `Grandmaster`, `Warlord`, and `Legend` tiers with RP progress and match reward multipliers.
- **Daily Missions & Daily Chest (`DailyMissionSystem.swift`, `MissionsView.swift`):** Rotates 3 distinct random missions daily; completing 3/3 unlocks a Daily Mission Chest with 1% unowned skin drop chance and 99% random Gold & Diamonds capped at `<= 1,000` each.
- **World Conquest (`WorldMapData.swift`, `WorldMapView.swift`):** Added all 6 inhabited continents with 8 representative countries each (`48` stages total) and procedural native SwiftUI flags; completing 8/8 countries unlocks the next continent automatically.
- **4-Zone Native Shop & StoreKit 2 (`SkinCatalog.swift`, `HeroChestSystem.swift`, `StoreKitManager.swift`, `ShopView.swift`, `ParentGateView.swift`):** Added Skins (Gold / Diamonds / Real-Money StoreKit 2), Diamond Hero Chests (`Common`, `Rare`, `Super`), Real-Money Gold Store, Real-Money Diamond Store, Parent Gate, and full 5-tab SwiftUI Home Hub (`ContentView`, `HomeView`, `RewardModalView`, `SettingsView`, `MatchEndOverlayView`, `PlayerProfileStore`).
- **Tests:** Updated `CollisionTests` and `LocalizationTests`; added `ProgressionAndEconomyTests` covering proportional rewards, 10 ranks, 3 daily missions, 2,000-roll 1% skin / `<= 1,000` chest cap, 6×8 World unlock logic, and `PlayerProfileStore` persistence.

### Added — Step 2 (Collisions, 5 End States, Bot AI, Top 5 Leaderboard, HUD)
- Ported deterministic grid `CollisionDetector` covering all 5 end outcomes (`selfTrail`, `enemyTrail`, `boundary`, `headOn`, and `starvation`/`victory` at 100%).
- Implemented `BotAI` supporting 10–15 bots (`12` default) with `Easy`, `Normal`, and `Hard` difficulty tiers, short-arc expansion, trail hunting, self-trail/dead-end avoidance, retreat-home defense, and `2.0–3.0s` empty-area respawns.
- Implemented `Leaderboard` (`Top 5` + human rank row if outside Top 5) and `MatchSettings`.
- Added `HudOverlayView` (top `%` bar, kill counter, Top 5 leaderboard, pause/resume, end-of-match summary card) and updated `ArenaScene` with pooled entity nametags and `#1` leader crown.
- Added XCTests: `CollisionTests`, `BotAITests`, `LeaderboardTests`, and `GameEngineTests`.

### Added — Step 1 (iOS Project Scaffolding, CI, Grid, Movement, Flood Fill, SpriteKit Demo)
- Created `ios/` project architecture configured via XcodeGen (`ios/project.yml`, deployment target iOS 16.0, Swift 5.9).
- Configured `.swiftlint.yml`, `.swiftformat`, and `.github/workflows/ios.yml` (`macos-latest` CI for lint, format check, build, and `xcodebuild test`).
- Implemented `GameConfig`, `GridMap` (`120x120`), zero-allocation `FloodFill` (exterior BFS with virtual perimeter halo), `Trail`, `InputQueue` (max-2 turn buffer blocking 180° reversal), and `Entity`.
- Implemented SpriteKit `ArenaScene` with dirty-rect `[UInt32]` `TerritoryTextureRenderer`, pooled trail sprites, direct `touchesBegan`/`touchesMoved` swipe steering, keyboard arrow/WASD steering, and `CameraController`.
- Added `Localizable.xcstrings` (100% English) and initial XCTests (`GridMapTests`, `FloodFillTests`, `MovementAndInputTests`, `LocalizationTests`).
