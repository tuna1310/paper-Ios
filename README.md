# Paper Territory (iOS Native)

**Paper Territory** is a native iOS (`Swift 5.9+`, `SwiftUI` + `SpriteKit`) territory-capture arcade game inspired by paper-cut .io mechanics, featuring 100% original procedural graphics, skins, and audio, strictly English in-game UI, and zero third-party runtime dependencies.

---

## Project Structure

```
.
├── .github/workflows/ios.yml    # macOS CI: XcodeGen, SwiftLint, SwiftFormat, xcodebuild test
├── ios/
│   ├── project.yml              # XcodeGen spec (iOS 16.0+, zero 3rd-party pods/SPM)
│   ├── .swiftlint.yml           # Strict SwiftLint rules (forbids ! casts / try!)
│   ├── .swiftformat             # Formatting rules aligned with SwiftLint
│   ├── PaperTerritory/
│   │   ├── App/                 # App entry point, ContentView, L10n wrapper
│   │   ├── Core/                # GameConfig, InputQueue, CameraController, FrameMetrics, SeededRandomGenerator
│   │   ├── Game/                # GridMap (120x120), FloodFill, Trail, Entity, CollisionDetector, BotAI, Leaderboard, GameEngine
│   │   ├── Rendering/           # TerritoryTextureRenderer (dirty-rect UInt32 -> SKTexture), ArenaScene
│   │   ├── Skins/               # Deterministic palette module
│   │   ├── Data/                # MatchSettings & rule configurations
│   │   ├── UI/                  # SwiftUI HUD & playable match views
│   │   └── Resources/           # Localizable.xcstrings (English), Info.plist, Assets.xcassets
│   └── PaperTerritoryTests/     # XCTest suite ported & extended from web logic tests
├── UI_NOTES.md                  # Visual audit & layout tokens from reference captures
├── PORTING_MAP.md               # TS/Kotlin reference ↔ Swift module & test mapping
├── DECISIONS.md                 # Architectural decisions & performance notes
├── IOS_SETUP.md                 # Mac XcodeGen, Simulator, device & TestFlight instructions
├── CHANGELOG.md                 # Milestone history
└── IDEAS.md                     # Future roadmap ideas
```

---

## Key Features (Steps 1–2)

- **120×120 Grid & Exterior BFS Flood Fill:** Zero-allocation `[UInt8]` grid, `5×5` starter territories, virtual perimeter flood fill with anti-overflow guarantee and rival-territory enclosure capture.
- **Responsive 4-Way Movement & Turn Buffer:** Max-2 command `InputQueue` blocking 180° U-turns, snapping cleanly at cell centers via direct `SKScene` touch swipes and keyboard arrows/WASD.
- **Deterministic Collision Rules & 5 States:** Self-trail, enemy trail cut (clears victim territory to neutral), configurable `EdgeRule` (`die` vs `block`), configurable `HeadOnRule` (`largerTerritoryWins` vs `bothDie`), starvation, and 100% victory.
- **12 Autonomous Bots (`10–15` configurable):** `Easy` / `Normal` / `Hard` tiers with short-arc expansion, exposed trail hunting, dead-end & self-trail avoidance, panic retreat, and `2.0–3.0s` empty-area respawns.
- **Zero-Allocation Render Loop:** Single `SKScene.update` fixed `1/60s` loop, dirty-rect `SKMutableTexture` territory rendering, and pooled `SKSpriteNode` trails/entities.

---

## Building & Testing

See [IOS_SETUP.md](IOS_SETUP.md) for Mac setup (`xcodegen generate`), running tests in Xcode, profiling Release 60/120 Hz performance, and archiving for TestFlight. Continuous build, lint, format, and `xcodebuild test` checks run on GitHub Actions via `.github/workflows/ios.yml`.
