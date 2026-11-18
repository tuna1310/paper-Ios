# CI Failures Root-Cause Log (`iOS CI` — `feature-paperio-ios`)

## Diagnostic Method & Tooling Availability
- `gh` CLI is not installed/authenticated in this Windows environment (`where.exe gh` returned nothing), and GitHub's raw zip `/actions/runs/{id}/logs` REST endpoint returns `HTTP 403 Must have admin rights to Repository` without an authenticated token.
- All actual run metadata, per-step outcomes, uploaded artifacts, and check-run failure annotations below were retrieved directly from the public GitHub Actions REST API:
  - `GET /repos/tuna1310/paper-Ios/actions/runs?branch=feature-paperio-ios`
  - `GET /repos/tuna1310/paper-Ios/actions/runs/{run_id}/jobs`
  - `GET /repos/tuna1310/paper-Ios/actions/runs/{run_id}/artifacts`
  - `GET /repos/tuna1310/paper-Ios/check-runs/{job_id}/annotations`
- If full raw `xcodebuild` stdout is ever needed locally, authenticate GitHub CLI (`gh auth login`) and run:
  ```bash
  gh run list --workflow "iOS CI" --limit 5
  gh run view 44272607284 --log-failed
  ```
  (Specifically inspect the `Build & Run Unit Tests (iOS Simulator)` or `Summarize Full Errors & Emit Annotations` step log.)

---

## Real Failure Root Causes (`Runs #1–#5`)

| Run | Run ID | Commit | Workflow Result | IPA Artifact Present? | Exact Failing Steps / Exit Codes | Observed Root Causes |
|---|---|---|---|---|---|---|
| **#1** | `44267623163` | `8a6cc98` | `failure` | `PaperTerritory-unsigned-ipa` (`440,831` B) uploaded, but job turned red | `Enforce All CI Gates` (`1`) reflecting: `SwiftFormat` (`1`), `xcodebuild test` (`70`), `SwiftLint` (`2`) | (1) Single-job design caused lint/test gates to mark the entire run failed. (2) `xcodebuild test` exited `70` on destination lookup / `TEST_HOST`. (3) Style warnings in `SwiftLint --strict` and `SwiftFormat --lint` failed gates. |
| **#2** | `44268686462` | `3902c2f` | `failure` | **NONE** (`ios-ci-logs` only, `703` B — IPA step **skipped**) | `Select eligible iOS Simulator` (`1`) -> skipped `test`, `DeviceIPA`, `lint`, `format`, `Upload Unsigned IPA` | `macos-latest` defaulted to `Xcode 26.6`, which had **no preinstalled iOS Simulator runtime** (`xcodebuild -showdestinations` only listed placeholder `"Any iOS Simulator Device"`). Because Simulator selection did not have `continue-on-error: true` and ran before `DeviceIPA` in the same job, its failure aborted the entire IPA build. |
| **#3** | `44269472092` | `aa38b51` | `failure` | `PaperTerritory-unsigned-ipa` (`440,831` B) uploaded, job turned red | `Enforce All CI Gates` (`1`) reflecting: `XcodeTest` (`70`), `SwiftLint` (`2`), `SwiftFormat` (`1`) | (1) `ios/project.yml` set `TEST_HOST` with `$(BUNDLE_EXECUTABLE_NAME)`, which expanded inside `PaperTerritoryTests` to `PaperTerritoryTests` instead of `PaperTerritory` (fixed in `365438e`). (2) `-destination id=...` lacked `platform=iOS Simulator,` warning (fixed in `773c034`). (3) `SwiftLint` flagged `BotAI.swift:5` (`type_body_length` `430 > 350`) and `for_where` lines `235`, `459` (fixed in `e74baec`). (4) `SwiftFormat` flagged `wrapLoopBodies` in `FloodFillTests.swift` and `spaceAroundOperators` (`0..<` vs SwiftFormat 0.55+ default `--ranges spaced`) in `FloodFillTests.swift` / `LeaderboardTests.swift` (fixed in `e74baec`). |
| **#4** | `44272607284` | `f2b1570` | `failure` | `PaperTerritory-unsigned-ipa` (`441,027` B) uploaded, job turned red | `Enforce All CI Gates` (`1`) reflecting: `XcodeTest` (`65`), `SwiftFormat` (`1`) (`SwiftLint` passed with `0` violations) | (1) `BotAITests.testBotsSimulate10SecondsWithoutSelfSuicides`: 1 `.hard` bot suffered `selfTrail` suicide (`1 != 0`, ~22s runtime) because `BotAI` lacked pocket reachability checks (`BotReachabilityAnalyzer` added in `8470142`). (2) `MovementAndInputTests.testEntityExecutesBufferedTwoStepCornerAtCellCenters` got `(60.5, 60.5)` instead of `(61.5, 61.5)` because `Entity.advance` called `applyQueuedTurnIfAtCenter` inside the step loop (`Entity.swift:78`, fixed in `8470142`). (3) `SwiftFormat` flagged `wrapIfStatementBodies` (`Leaderboard.swift:36-37`, `CollisionTests.swift:23-24,45-46,88-89`, `InputQueue.swift:10-11`, etc.) across `12/33` files (config + `format-fix.yml` added in `e2dca4b`). |
| **#5** | `44315846470` | `e2dca4b` | `cancelled` | **NONE** (`0` artifacts) | `Build, Test & Unsigned IPA (iOS)` (`cancelled`) | Canceled manually (`The run was canceled by @tuna1310`) before execution completed on `macos-latest` (`arm64` capacity queue delay). |
| **#6** | `44321341699` | `9693ab9` | `failure` (`build-ipa` ✅, `test-and-lint` ❌) | **`paperio-unsigned-ipa` (`437,911` B)** + `ios-ci-logs` (`116,009` B) | `Enforce Test & Lint Gates` (`1`) reflecting **only** `Check SwiftFormat` | `build-ipa`, `XcodeGen`, `Simulator`, **`XcodeTest`**, and **`SwiftLint`** all passed ✅. `SwiftFormat --lint` failed only on `wrapIfStatementBodies` (`Leaderboard.swift:36-37`, `CollisionTests.swift:23-24,45-46,88-89`, `InputQueue.swift:10-11`, plus remaining single-line `if` bodies in `Types.swift`, `FloodFill.swift`, `BotSpawner.swift`, `BotNavigation.swift`, `ArenaScene.swift`). Fixed directly across all 8 files. |

---

## Workflow Fixes Applied After Run #5
1. **Separated `build-ipa` from `test-and-lint`:** IPA creation and upload run in a standalone `build-ipa` job so Simulator availability, unit test failures, SwiftLint, or SwiftFormat warnings can never block or skip producing the IPA artifact.
2. **Pinned macOS Runner & Xcode Version:** Switched both jobs from unpinned `macos-latest` (`Xcode 26.6`, missing preinstalled Simulator runtimes) to `macos-15` with explicit `sudo xcode-select -s /Applications/Xcode_16.4.app/Contents/Developer` (`Xcode 16.4`, preinstalled `iOS 18.5` SDK and `iPhone 16` Simulator runtime).
3. **Standardized IPA Packaging, Logging & Artifact Contract:**
   - Builds `Release` with `-sdk iphoneos -destination "generic/platform=iOS"`, `CODE_SIGNING_ALLOWED=NO`, `CODE_SIGNING_REQUIRED=NO`, `CODE_SIGN_IDENTITY=""`.
   - Packages `Payload/PaperTerritory.app` into `artifacts/PaperTerritory-unsigned.ipa`.
   - Prints exact IPA path and byte size in a dedicated step.
   - Uploads with `actions/upload-artifact@v4` using `name: paperio-unsigned-ipa`, `if-no-files-found: error`, `retention-days: 14`.
