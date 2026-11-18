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
│   │   ├── Core/                # GameConfig, InputQueue, CameraController, FrameMetrics
│   │   ├── Game/                # GridMap (120x120), FloodFill, Trail, Entity, GameEngine
│   │   ├── Rendering/           # TerritoryTextureRenderer (dirty-rect UInt32 -> SKTexture), ArenaScene
│   │   ├── Skins/               # Deterministic palette module
│   │   ├── UI/                  # SwiftUI demo match view
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

## Building & Testing

See [IOS_SETUP.md](IOS_SETUP.md) for Mac setup (`xcodegen generate`), running tests in Xcode, profiling Release 60/120 Hz performance, and archiving for TestFlight. Continuous build, lint, format, and `xcodebuild test` checks run on GitHub Actions via `.github/workflows/ios.yml`.
