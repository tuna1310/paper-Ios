# Ideas & Deferred Scope — Paper Territory (iOS)

Items intentionally kept out of scope for the current milestone and logged here for future iterations:

1. **Real StoreKit 2 In-App Purchases:** Replace `SimulatedPurchaseService` with StoreKit 2 `Product.purchase()` verification, receipt/transaction listener, and Restore Purchases button once Apple Developer Connect products are configured.
2. **Rewarded Video Ad SDK (Optional):** Currently the "Revive" ad option is an internal simulation with zero tracking SDKs and zero `NSUserTrackingUsageDescription`. If monetization is added later, integrate an age-appropriate SDK with App Tracking Transparency review and update `PrivacyInfo.xcprivacy` + App Store privacy labels.
3. **World Map Conquest Campaign:** Country polygon data (`GeoJSON` / vector silhouettes) and progressive continent unlocking beyond the core Arena / Team Battle modes (stubbed as a data framework in Step 7).
4. **Game Center Leaderboards & Achievements:** Native `GKLeaderboard` and `GKAchievement` integration once Bundle ID and App Store Connect capabilities are registered.
5. **Custom Haptic Patterns (CoreHaptics):** Upgrade `UIImpactFeedbackGenerator` to `.ahap` CoreHaptics waveforms for multi-kill streaks and territory capture sweeps.
6. **iCloud Key-Value / CloudKit Sync:** Sync gems, unlocked skins, and best percentage across iPhone and iPad.
