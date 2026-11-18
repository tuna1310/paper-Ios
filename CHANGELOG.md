# Changelog

All notable changes to **Paper Territory (iOS)** are documented in this file.

## [Unreleased]

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
