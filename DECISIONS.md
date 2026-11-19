# Technical & Product Decisions — Paper Territory (iOS)

This log documents architectural choices, reconciled requirements, formulas, and performance measurements for **Paper Territory (iOS)**.

---

## Decision 1: Pure Native iOS Module Layout under `ios/`
- **Decision:** Build the entire native iOS app inside `ios/` using XcodeGen (`ios/project.yml`), Swift 5.9+, SwiftUI for menus/HUD, and SpriteKit (`SKScene` via `SpriteView`) for gameplay. Keep `PaperIO2/` (legacy uncompiled draft at repo root) untouched and never modify `../paper.io adr`.
- **Rationale:** Matches scope boundary (`ios/` only), enforces strict zero-third-party-runtime dependency, keeps `.xcodeproj` generated rather than committed, and enables automated macOS GitHub Actions CI (`xcodegen generate`, `swiftlint`, `swiftformat --lint`, `xcodebuild test`).

## Decision 2: Reconciling `120x120` 4-Directional Grid Rules vs `240x240` Circular Web Prototype
- **Context:** The `../paper.io adr/src/` prototype evolved into a `240x240` circular free-angle variant with self-trail immunity and soft head-on bounces, whereas the iOS specification explicitly mandates:
  - `120x120` integer grid (`ownerId: UInt8`, `0 = neutral`), `5x5` starter territory (`radius = 2`).
  - Continuous movement along 4 cardinal directions (`up`, `down`, `left`, `right`), turns executed cleanly at cell centers via a max-2 command queue blocking 180° reversals.
  - Self-trail collision eliminates the player; enemy hitting your trail eliminates you; hitting enemy trail eliminates the enemy and resets their territory to neutral (`0`); configurable Edge Rule (`die` vs `block`); configurable Head-On Rule (`largerTerritoryWins` vs `bothDie`); `100%` map capture triggers victory.
- **Decision:** Implement the exact `120x120` 4-directional specification in `ios/PaperTerritory/Game/` while porting the proven algorithmic invariants from the web prototype (exterior BFS flood fill with bounding-box pruning, O(1) cell counts, dirty-rect tracking, bot personalities/respawn, Top 5 leaderboard, and fixed `1/60s` simulation step).

## Decision 3: Exterior Flood Fill with Virtual 1-Cell Exterior Halo
- **Problem:** Bounding a flood fill solely to a trail's box can miss enclosed pockets bounded by concave parts of a player's own existing territory, and clamping to grid edges `0`/`119` can either miss border loops or risk incorrect border fills.
- **Decision:** Track the union bounding box of a player's existing territory and active trail, then run BFS inside a `(width + 2) x (height + 2)` virtual padded space (`-1...gridWidth`, `-1...gridHeight`) using preallocated reusable `[UInt8]` (`visited`) and `[Int32]` (`queue`) buffers (~75 KB once per engine).
- **Result:**
  - Zero per-capture heap allocations.
  - Mathematically guaranteed **anti-overflow**: any unclosed gap leaks from the virtual exterior border so 0 non-enclosed cells are captured.
  - Captures both neutral (`0`) and rival territory enclosed inside any closed loop, including C-shaped bays and multi-island territories.

## Decision 4: 60 FPS / 120 Hz ProMotion Zero-Allocation Render Architecture
- **Lesson Learned from Android:** Creating paths, arrays, or per-cell nodes inside the frame loop causes severe frame pacing stutter.
- **Decision:**
  1. **Single Loop & Fixed Timestep:** Drive both simulation and rendering from `SKScene.update(_:)` (`CADisplayLink`-backed). Accumulate elapsed time (`dt <= 0.05s` clamp) and step `GameEngine.tick(fixedDt: 1/60)` up to 3 steps per frame.
  2. **Dirty-Rect Pixel Buffer Territory (`TerritoryTextureRenderer`):** Maintain a single preallocated `[UInt32]` RGBA buffer (`240x240` = 2×2 pixels per cell for crisp top highlight + bottom bevel 2.5D paper depth, ~230 KB). Only iterate over `dirtyRect` when grid ownership changes, uploading a single `SKTexture` with `.nearest` filtering onto one `SKSpriteNode`. **0 bytes allocated and 0 GPU uploads on frames without grid changes.**
  3. **Pooled Trails & Entities:** Preallocate reusable `SKSpriteNode` trail segment pools and fixed entity sprite nodes (`SKSpriteNode` body + eye/shadow children + `SKLabelNode`) at match initialization; toggle `.isHidden` instead of adding/removing nodes.
  4. **Direct Touch Handling:** Read `touchesBegan` / `touchesMoved` directly on `ArenaScene` with a crisp swipe distance threshold (`14pt`) to push into the 2-slot `InputQueue` without SwiftUI gesture dispatch latency.

## Decision 5: Five Explicit Match End States & Collision Semantics
- `GameState` models `.ready`, `.playing`, `.paused`, `.victory`, `.gameOver(DeathReason)`.
- `CollisionDetector` produces deterministic, priority-ordered outcomes for the 5 core end/collision scenarios:
  1. `selfTrail`: Head enters cell occupied by own active trail (when outside own territory).
  2. `enemyTrail(killerId:)`: Head enters cell occupied by another alive entity's active trail → trail owner dies and their territory clears to `0`.
  3. `outOfBounds`: Head crosses map boundary `[0, gridSize)` when `EdgeRule == .die` (when `EdgeRule == .block`, position clamps smoothly inside the arena edge).
  4. `headOn(killerId:)`: Two heads occupy the same cell (or cross paths on the same tick) → when `HeadOnRule == .bothDie` both die; when `.largerTerritoryWins`, smaller territory dies (tie → both die).
  5. `starvation` / `victory`: Losing all territory cells eliminates an entity (`starvation`), while conquering `100%` of the playable grid ends the match in `.victory`.

## Decision 6: Localization Architecture (`Localizable.xcstrings`)
- **Decision:** Store all user-facing strings in `ios/PaperTerritory/Resources/Localizable.xcstrings` (`sourceLanguage: "en"`) and resolve via `L10n` wrapper calling `String(localized:bundle:)`. Enforce via unit tests (`LocalizationTests`) that zero Vietnamese characters appear in any localized string or bot name.

## Decision 7: SwiftFormat & SwiftLint Configuration Adjustments
- **Decision:** Configure `ios/.swiftformat` with `--ranges nospace` and disable `redundantSelf`, `blankLinesAroundMark`, `numberFormatting`, `andOperator`, `sortedImports`, `conditionalAssignment`, `nestedIf`, `wrapPropertyBodies`, and `wrapMultilineStatementBraces`; keep `wrapIfStatementBodies`, `wrapLoopBodies`, and `redundantReturn` enabled and enforce automated formatting via `.github/workflows/format-fix.yml`; keep all SwiftLint safety & standard brace rules (`opening_brace`, `force_cast: error`, `force_try: error`, `force_unwrapping: error`, `implicitly_unwrapped_optional`, `type_body_length: 350`) strictly active by decomposing `BotAI` into `BotNavigation` (`BotReachabilityAnalyzer`) + `BotSpawner`.
- **Rationale:**
  - `conditionalAssignment` rewrites explicit `if/else` assignments into Swift 5.9 `if` expressions that hinder debugger stepping and long-line readability.
  - `nestedIf` rewrites/combines nested conditionals in ways that clash with keeping `andOperator` disabled (`if a && b` readability).
  - `wrapPropertyBodies` expands concise 1-line computed properties (`var cellX: Int { Int(floor(posX)) }`) onto 3 lines, inflating line counts near SwiftLint thresholds (`file_length`/`type_body_length`) without clarity gains.
  - `wrapMultilineStatementBraces` forces `{` onto a standalone new line on multiline statements, directly contradicting SwiftLint's default `opening_brace` rule and Apple's standard same-line brace style; disabling it keeps both tools 100% aligned.
  - Conversely, `wrapIfStatementBodies` and `redundantReturn` produce uniform, clean modern Swift and are applied automatically on `macos-latest` via `.github/workflows/format-fix.yml`.

## Decision 8: Paper.io 2 Gameplay Ruleset, Dual Currency, 10 Ranks, Daily Chest, 6x8 World Map & Native StoreKit 2 Shop
- **Gameplay Ruleset Update (`Entity.swift`, `CollisionDetector.swift`):**
  - Crossing your own active trail is **non-lethal** (`processEnteredCellCenter` deduplicates trail cells without setting `enteredSelfTrail`).
  - A player is only eliminated when **outside their own territory** and struck on their exposed trail (or losing a head-on clash outside their own territory / hitting an eliminate border / zero-territory starvation). In head-on clashes, a defender standing inside their own territory automatically eliminates an outside invader, and two players simultaneously inside their own territories both survive.
- **Dual Currencies & 10-Tier Rank Ladder (`RankSystem.swift`):**
  - Every completed match awards **Gold** (`~6.0 × %` + kill/victory/rank-multiplier bonuses) and **Diamonds** (`~0.45 × %` + kill/victory/rank-multiplier bonuses) scaled proportionally to territory percentage achieved (`max(peakPercentage, finalPercentage)`).
  - 10 competitive tiers mapped 1:1 from Bronze to Legend (`Bronze`, `Silver`, `Gold`, `Platinum`, `Diamond`, `Elite`, `Master`, `Grandmaster`, `Warlord`, `Legend`) with progressive RP thresholds (`0` to `6,500`) and `+5%` per-tier reward multiplier.
- **Daily Missions & Daily Mission Chest (`DailyMissionSystem.swift`):**
  - Deterministically rotates **3 distinct random missions per UTC day** (`yyyy-MM-dd`).
  - Completing `3/3` missions unlocks 1 **Daily Mission Chest** with a **1% chance** to drop an unowned skin and a **99% chance** to grant random Gold (`100...1,000`) and Diamonds (`20...1,000`), strictly capped at `<= 1,000` each.
- **World Conquest (`WorldMapData.swift`):**
  - 6 inhabited continents (`Asia`, `Europe`, `North America`, `South America`, `Africa`, `Oceania`) × **8 representative countries each (`48` stages total)** with native procedural SwiftUI flags (`CountryFlagBadgeView`) and `76×76` conquest arenas.
  - Asia starts unlocked; conquering `8/8` countries in continent `N` automatically unlocks continent `N + 1`.
- **Native 4-Zone Shop & StoreKit 2 (`SkinCatalog.swift`, `HeroChestSystem.swift`, `StoreKitManager.swift`, `ShopView.swift`, `ParentGateView.swift`):**
  - 100% pure native SwiftUI + Apple `StoreKit` 2 (zero third-party SDKs), protected by a kid-safe math `ParentGateView` before real-money purchases:
    1. **Skins:** 19 procedural skins purchasable with Free/Gold/Diamonds/Real-Money StoreKit 2.
    2. **Hero Chests (Diamonds):** `Common Chest` (`50`), `Rare Chest` (`150`), and `Super Chest` (`400`).
    3. **Gold Store:** Real-money Gold packs via `StoreKit` 2.
    4. **Diamond Store:** Real-money Diamond packs via `StoreKit` 2.

## Performance Measurements Log
- *Baseline (Simulator CI / Windows authoring environment):* Benchmarks for FloodFill, GridMap dirty updates, and 15-bot 10-second simulation runs are executed in `GameEngineTests` / `FloodFillTests` on `macos-latest` CI; physical iPhone 60/120 Hz frame-time telemetry (`FrameMetrics` via `CACurrentMediaTime()` + `os_signpost`) will be recorded here once profiled on hardware.
