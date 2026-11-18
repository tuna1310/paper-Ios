# Changelog

All notable changes to **Paper Territory (iOS)** are documented in this file.

## [Unreleased]

### Added — Step 1 (iOS Project Scaffolding, CI, Grid, Movement, Flood Fill, SpriteKit Demo)
- Created `ios/` project architecture configured via XcodeGen (`ios/project.yml`, deployment target iOS 16.0, Swift 5.9).
- Configured `.swiftlint.yml`, `.swiftformat`, and `.github/workflows/ios.yml` (`macos-latest` CI for lint, format check, build, and `xcodebuild test`).
- Implemented `GameConfig`, `GridMap` (`120x120`), zero-allocation `FloodFill` (exterior BFS with virtual perimeter halo), `Trail`, `InputQueue` (max-2 turn buffer blocking 180° reversal), and `Entity`.
- Implemented SpriteKit `ArenaScene` with dirty-rect `[UInt32]` `TerritoryTextureRenderer`, pooled trail sprites, direct `touchesBegan`/`touchesMoved` swipe steering, keyboard arrow/WASD steering, and `CameraController`.
- Added `Localizable.xcstrings` (100% English) and initial XCTests (`GridMapTests`, `FloodFillTests`, `MovementAndInputTests`, `LocalizationTests`).
