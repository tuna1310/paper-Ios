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

*(Awaiting first remote CI run after user pushes `feature-paperio-ios`.)*
