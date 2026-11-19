# Porting Map — Web/Android Prototype → iOS Native (`ios/`)

This document tracks how modules and tests from the reference prototype (`../paper.io adr/src/` and `../paper.io adr/tests/`) map to the native Swift + SwiftUI + SpriteKit iOS codebase under `ios/`.

> **Important Reconciliation:** The reference prototype in `../paper.io adr/src/` transitioned mid-project to a `240x240` circular free-angle Paper.io 2 variant, whereas the native iOS specification requires the deterministic **`120x120` 4-directional grid** ruleset (max-2 command turn queue at cell centers, `5x5` starter territory, self-trail elimination, configurable Edge & Head-on rules, and `100%` territory victory). Logic invariants (exterior BFS flood fill, grid dirty tracking, collision classification, bot archetypes/respawn, Top 5 leaderboard, and fixed-timestep decoupling) are ported faithfully and adapted to the 4-directional `120x120` grid model.

---

## Source Files Mapping

| Reference Prototype (`../paper.io adr/`) | iOS Native (`ios/PaperTerritory/`) | Step | Notes / Adaptation |
|---|---|---|---|
| `src/config.ts` & `GameConfig.kt` | `Core/GameConfig.swift` | Step 1–2 | Centralizes `gridSize = 120`, `cellSize`, `starterRadius = 2` (`5x5`), `turnQueueCapacity = 2`, speeds, `botCount = 12` (`10...15`), `respawnDelay = 2.5s`, difficulty & rule enums. Zero magic numbers in logic. |
| `src/engine/types.ts` | `Game/Types.swift` | Step 1–2 | `Direction`, `GridPoint`, `GridRect`, `EdgeRule`, `HeadOnRule`, `BotDifficulty`, `BotArchetype`, `DeathReason`, `GameState`, `CaptureResult`, `CollisionEvent`, `LeaderboardEntry`. |
| `src/engine/GridMap.ts` | `Game/GridMap.swift` | Step 1 | Contiguous `[UInt8]` (`120 * 120 = 14,400` cells), `ownerId` (`0 = neutral`), O(1) cell counts per owner, dirty bounding rect tracking (`dirtyRect`) for zero-waste texture updates, `initStarterTerritory` (`5x5`). |
| `src/engine/FloodFill.ts` | `Game/FloodFill.swift` | Step 1 | Preallocated reusable `visited` and `bfsQueue` buffers (zero per-capture heap allocations). Stamps trail cells + runs bounded exterior BFS with 1-cell virtual perimeter halo so open loops never overflow and enclosed rival territory is captured. |
| `src/engine/Trail.ts` | `Game/Trail.swift` | Step 1 | Preallocated flat array / ring buffer of trail grid coordinates + O(1) lookup flags (`trailMask` or packed `Int32`) to avoid allocations during gameplay. |
| `src/engine/Player.ts` | `Game/Entity.swift`, `Core/InputQueue.swift` | Step 1 | Continuous grid-space movement along 4 cardinal `Direction`s, cell-center alignment, max-2 `InputQueue` blocking 180° reversals, trail recording outside own territory, loop closure trigger upon re-entering own territory. |
| `src/engine/CollisionDetector.ts` | `Game/CollisionDetector.swift` | Step 2 | Evaluates all 5 end outcomes: (1) self-trail hit, (2) enemy hits trail, (3) boundary hit (`EdgeRule.die` vs `.block`), (4) head-on collision (`HeadOnRule.largerTerritoryWins` vs `.bothDie`), (5) zero-territory starvation / 100% victory. |
| `src/ai/BotController.ts` | `Game/BotAI.swift`, `Game/BotNavigation.swift`, `Game/BotSpawner.swift` | Step 2 | 12 bots (`10...15` configurable) with 3 difficulties (`Easy`, `Normal`, `Hard`) & personalities: short-arc territory expansion, hunting nearby exposed player/rival trails, avoiding own trail & dead ends, retreating home when threatened, `2.0–3.0s` empty-area respawn. |
| `src/engine/GameEngine.ts` | `Game/GameEngine.swift`, `Game/Leaderboard.swift` | Step 1–2 | Fixed `1/60s` timestep match orchestrator, Top 5 leaderboard + human rank extraction, clear state reset on match start, English notifications. |
| `src/ui/TerritoryRenderer.ts`, `GameRenderer.ts` | `Rendering/TerritoryTextureRenderer.swift`, `Rendering/ArenaScene.swift` | Step 1–3 | Dirty-rect `[UInt32]` pixel buffer -> single `SKTexture`, pooled `SKSpriteNode` trail segments & entity nodes, smooth camera follow, zero allocations in `SKScene.update`. |
| `src/ui/InputController.ts` | `Rendering/ArenaScene.swift`, `Core/InputQueue.swift` | Step 1 | Direct `touchesBegan`/`touchesMoved` swipe vector detection inside `SKScene` (bypassing SwiftUI gesture latency) + iPad/Simulator arrow/WASD keyboard steering. |
| `src/ui/HudRenderer.ts` | `UI/HudOverlayView.swift`, `UI/MatchEndOverlayView.swift` | Step 2–3 | SwiftUI HUD overlay displaying % progress bar (with World stage goal), kill counter, Top 5 leaderboard, pause/restart/home controls, and match-end reward breakdown card. |
| `src/meta/*` & `src/ui/screens/*` | `Data/PlayerProfileStore.swift`, `Skins/SkinCatalog.swift`, `Meta/RankSystem.swift`, `Meta/DailyMissionSystem.swift`, `Meta/WorldMapData.swift`, `Meta/HeroChestSystem.swift`, `Meta/StoreKitManager.swift`, `UI/*` | Paper.io 2 Native | 100% pure native SwiftUI + StoreKit 2: dual Gold/Diamonds economy, 10 rank tiers (`Bronze`–`Legend`), 3 daily random missions + 1%/`<=1,000` Daily Chest, 6 continents × 8 countries World Conquest, 19 procedural skins, Common/Rare/Super Diamond Hero Chests, Real-Money Gold/Diamond stores, Parent Gate, and `UserDefaults` persistence. |

---

## Test Suite Mapping

| Reference Prototype Test (`../paper.io adr/tests/`) | iOS Native XCTest (`ios/PaperTerritoryTests/`) | Step |
|---|---|---|
| `tests/engine/GridMap.test.ts` | `GridMapTests.swift` | Step 1 |
| `tests/engine/FloodFill.test.ts` | `FloodFillTests.swift` | Step 1 |
| `tests/engine/Player.test.ts` | `MovementAndInputTests.swift` | Step 1 |
| `tests/engine/Collision.test.ts` | `CollisionTests.swift` | Step 2 + Paper.io 2 |
| `tests/engine/TerritoryClaiming.test.ts` | `FloodFillTests.swift`, `CollisionTests.swift` | Step 1–2 |
| `tests/ai/BotController.test.ts` | `BotAITests.swift` | Step 2 |
| `tests/engine/GameEngine.test.ts` | `LeaderboardTests.swift`, `GameEngineTests.swift` | Step 2 |
| *(New iOS requirement)* | `LocalizationTests.swift` | Step 1 + Paper.io 2 |
| *(New iOS requirement)* | `ProgressionAndEconomyTests.swift` | Paper.io 2 |
