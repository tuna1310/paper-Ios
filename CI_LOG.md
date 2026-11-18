# CI Log — Paper Territory (iOS)

Tracks every GitHub Actions CI run (`macos-latest`, `.github/workflows/ios.yml`) and fixes applied until green.

---

## Round 1 — Pre-Push Hardening & Initial Workflow Setup

- **Commit base:** `1395993` (docs), `580229e` (Step 1), `ceaf4a1` (Step 2)
- **Status:** Ready to push to `origin/feature-paperio-ios` via `tools/push.ps1`.
- **Pre-push preventive fixes applied before first remote run:**
  1. **CI workflow triggers & multi-stage diagnostics (`.github/workflows/ios.yml`):**
     - **Cause:** Initial workflow ran `swiftformat`/`swiftlint` from repo root (risking wrong CWD relative paths for `.swiftlint.yml` `included:` folders), exited early before running `xcodebuild test` if format failed, and overrode `CODE_SIGN_IDENTITY="-"` which can conflict with Simulator automatic signing.
     - **Fix:** Explicit `push`/`pull_request` triggers for `main` and `feature-paperio-ios` plus `workflow_dispatch`; execute `swiftformat --lint` and `swiftlint lint --strict` inside `ios/`; collect all 4 step logs (`swiftformat`, `swiftlint`, `xcodegen`, `xcodebuild`) in a single run with `Enforce All CI Gates` at the end.
  2. **SwiftFormat alignment (`ios/.swiftformat`):**
     - **Cause:** Default `numberFormatting` rejects 2-byte hex grouping (`0xFF_2A_6D`), `andOperator` rejects `if a && b`, and `sortedImports` has case-sensitivity edge cases (`os.signpost` vs `QuartzCore`).
     - **Fix:** Disabled `numberFormatting`, `andOperator`, and `sortedImports` in `ios/.swiftformat`.
  3. **Unsigned device `.ipa` & procedural AppIcon (`ios.yml`, `tools/generate_app_icon.mjs`):**
     - **Cause:** Windows cannot compile iOS binaries locally (`xcodebuild` is macOS-only), and installing onto a real iPhone via Sideloadly requires a compiled `arm64` `.ipa` with a valid `1024x1024` `AppIcon`.
     - **Fix:** Generated `AppIcon-1024.png` procedurally via code and added an `iphoneos` unsigned Release `.ipa` build + `PaperTerritory-unsigned-ipa` artifact upload to `.github/workflows/ios.yml`.

*(Awaiting first remote CI run after user pushes `feature-paperio-ios`.)*

---

## Round 2 — Run #1 (`44267623163`, commit `8a6cc98`) Analysis & Diagnostics Fix

- **Observed CI result (`macos-latest`):**
  - `PaperTerritory-unsigned-ipa` artifact (`440,831` bytes) compiled and uploaded successfully (`iphoneos` Release `arm64`), confirming app target Swift compilation succeeded.
  - Job failed at `Enforce All CI Gates` with 4 failure annotations (`exit code 1`, `70`, `2`, `1`) corresponding to `SwiftFormat` (`1`), `xcodebuild test` (`70`), `SwiftLint` (`2`), and the final gate (`1`).
  - Raw GitHub job logs endpoint returned `403 Must have admin rights to Repository` for unauthenticated reads.
- **Root causes identified & changes applied:**
  1. **Simulator destination exit code `70`:** `xcrun simctl list` can pick a simulator runtime belonging to a different Xcode installation than the active `xcode-select` SDK. Switched Simulator selection in `.github/workflows/ios.yml` to parse `xcodebuild -showdestinations` directly and boot the simulator prior to `xcodebuild test`.
  2. **Log visibility without admin token:** Reordered CI steps to prioritize `XcodeGen → Build & Test → Device IPA → SwiftLint → SwiftFormat`, and added `Summarize Errors & Emit Annotations` (`GITHUB_STEP_SUMMARY` + `::error::` annotations) so every error line is visible in one place and readable via public check-run annotations.

---

## Round 3 — Run #2 (`44268686462`, commit `3902c2f`) Simulator Runtime Provisioning

- **Observed CI result (`macos-latest`, Xcode 26.6):**
  - `Select eligible iOS Simulator` failed because the runner image did not have an iOS Simulator runtime preinstalled/available (`xcodebuild -showdestinations` only returned placeholder `"Any iOS Simulator Device"`).
  - Because `sim` did not have `continue-on-error: true`, subsequent `DeviceIPA`, `SwiftLint`, and `SwiftFormat` steps were skipped.
- **Root cause & Approach 1 fix applied:**
  1. Added full `simctl list runtimes` / `devices available` / installed Xcode / disk inventory logging (`artifacts/sim-inventory.txt` + Job Summary).
  2. In `Provision & Boot iOS Simulator` (now with `continue-on-error: true`), if no eligible iOS simulator or iOS runtime exists, execute `xcodebuild -downloadPlatform iOS`, create `"CI iPhone"` via `xcrun simctl create` if needed, boot it, and run `xcodebuild test -destination "id=<udid>"`.
  3. Kept `DeviceIPA`, `SwiftLint`, `SwiftFormat`, and `Summarize Errors & Emit Annotations` running on every pass so all error details surface together.
