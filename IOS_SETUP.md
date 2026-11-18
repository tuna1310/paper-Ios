# iOS Setup & TestFlight Guide — Paper Territory

Because the primary development environment is Windows, the Xcode project is generated from `ios/project.yml` via **XcodeGen** and validated continuously on GitHub Actions (`macos-latest`). Follow these steps when opening and building on a Mac.

---

## 1. Prerequisites on Mac

1. Install **Xcode 15+** from the Mac App Store and launch it once to accept the license and install iOS Simulator runtimes.
2. Install **XcodeGen**, **SwiftLint**, and **SwiftFormat** via Homebrew:
   ```bash
   brew install xcodegen swiftlint swiftformat
   ```

---

## 2. Generate the Xcode Project

The `.xcodeproj` bundle is intentionally excluded from Git (`.gitignore`). Generate it locally from `ios/`:

```bash
cd ios
xcodegen generate
open PaperTerritory.xcodeproj
```

---

## 3. Run Locally on iPhone Simulator or Physical iPhone

1. In Xcode, select the **PaperTerritory** scheme.
2. **To run on Simulator:** choose any iPhone 15/16 or iPad Simulator (`iOS 16.0+`) and press `Cmd + R`.
3. **To run on a physical iPhone:**
   - Connect your iPhone via USB (enable **Settings → Privacy & Security → Developer Mode** on iOS 16+).
   - Select the **PaperTerritory** target → **Signing & Capabilities**.
   - Check **Automatically manage signing**, choose your Apple **Team**, and set a unique **Bundle Identifier** (e.g., `com.<yourname>.paperterritory`).
   - Select your physical iPhone in the scheme destination picker and press `Cmd + R`.
4. **Run Unit Tests:** press `Cmd + U` or run from terminal:
   ```bash
   xcodebuild test \
     -project ios/PaperTerritory.xcodeproj \
     -scheme PaperTerritory \
     -destination 'platform=iOS Simulator,name=iPhone 16'
   ```
5. **Run Lint & Format Checks (identical to CI):**
   ```bash
   (cd ios && swiftlint lint --strict --config .swiftlint.yml)
   (cd ios && swiftformat --lint --config .swiftformat .)
   ```
   Always pass `--config .swiftformat` from `ios/` (the single canonical config shared with `.github/workflows/ios.yml` and `.github/workflows/format-fix.yml`).

---

## 4. Profiling 60 FPS / 120 Hz Performance (Release Build)

Always measure performance on a physical device using **Release** configuration (never Debug only):

1. Edit Scheme → Run → Build Configuration → **Release** (keep `FrameMetrics` `os_signpost` active or enable FPS readout for profiling).
2. Run **Product → Profile (`Cmd + I`) → Time Profiler / Core Animation / Metal System Trace**.
3. Verify zero frame drops above `16.6ms` (60 Hz) or `8.3ms` (120 Hz ProMotion) during 15-bot matches and large territory captures.

---

## 5. Submitting to TestFlight

1. Bump `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` in `ios/project.yml` and regenerate with `xcodegen generate`.
2. Ensure an Apple Developer Program membership is selected under **Signing & Capabilities**.
3. Set destination to **Any iOS Device (arm64)** and choose **Product → Archive**.
4. In the Xcode Organizer window, select the archive → **Distribute App → TestFlight & App Store → Upload**.
5. In **App Store Connect**, complete export compliance (no custom encryption beyond standard HTTPS if applicable) and invite internal/external testers.

---

## 6. Installing on iPhone from Windows (via CI `.ipa` + Sideloadly / AltStore)

Because Windows cannot compile iOS binaries locally, `.github/workflows/ios.yml` builds an unsigned `arm64` device package in a dedicated `build-ipa` job on `macos-15` (`Xcode 16.4`). See [docs/INSTALL_IPA.md](docs/INSTALL_IPA.md) for full Sideloadly and AltStore steps, or summary:

1. Push your branch (`.\tools\push.ps1`) and wait for **iOS CI** (`Build Unsigned IPA (iOS)`) on GitHub Actions to finish.
2. Open the workflow run → **Artifacts** → download **`paperio-unsigned-ipa`** and unzip `PaperTerritory-unsigned.ipa`.
3. Plug your iPhone into Windows via USB (trust the computer on iPhone; enable **Settings → Privacy & Security → Developer Mode** on iOS 16+).
4. Open **Sideloadly** (or **AltStore**), sign `PaperTerritory-unsigned.ipa` with your Apple ID, and install.
5. On iPhone: **Settings → General → VPN & Device Management** → trust your developer certificate, then launch **Paper Territory**.

