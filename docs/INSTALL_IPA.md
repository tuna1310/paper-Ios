# Installing Unsigned `PaperTerritory` IPA on iPhone

This guide explains how to install the unsigned `.ipa` produced by the **iOS CI** workflow (`paperio-unsigned-ipa` artifact) onto a physical iPhone running **iOS 16.0+** from Windows or macOS using a free Apple ID.

> **Prerequisite on iPhone (iOS 16+):**
> Open **Settings → Privacy & Security → Developer Mode**, turn it **On**, and restart your iPhone if prompted. When plugging into your PC/Mac via USB for the first time, tap **Trust** on the iPhone prompt.

---

## 1. Download the IPA from GitHub Actions

1. Open the repository **Actions** tab on GitHub and click a completed **iOS CI** run.
2. Scroll down to the **Artifacts** section and download **`paperio-unsigned-ipa`**.
3. Extract the downloaded `.zip` archive to obtain `PaperTerritory-unsigned.ipa`.

---

## Option A — Install with Sideloadly (Windows or macOS)

1. Install **Sideloadly** (Windows requires web-installer iTunes + iCloud from Apple, not Microsoft Store versions) and connect your iPhone via USB.
2. Open **Sideloadly** and confirm your iPhone appears in **iDevice**.
3. Drag and drop `PaperTerritory-unsigned.ipa` onto the IPA icon.
4. Enter your **Apple ID** (free Apple IDs work; Sideloadly resigns the app locally with a 7-day personal development certificate).
5. Click **Start** and complete Apple ID / 2FA verification if prompted.
6. Once installed on your iPhone, go to **Settings → General → VPN & Device Management**, tap your Apple ID profile, and tap **Trust**.
7. Launch **Paper Territory** from the Home Screen. *(With a free Apple ID, re-sign via Sideloadly every 7 days or enable Sideloadly Wi-Fi auto-refresh.)*

---

## Option B — Install with AltStore (Windows or macOS)

1. Install **AltServer** on your PC/Mac (and **AltStore** onto your iPhone via AltServer using USB + Apple ID; on Windows, install non-Store iTunes & iCloud).
2. On iPhone, trust your Apple ID certificate in **Settings → General → VPN & Device Management**.
3. Transfer `PaperTerritory-unsigned.ipa` to your iPhone (Files app via AirDrop, iCloud Drive, or USB File Sharing).
4. Open **AltStore** on iPhone → go to the **My Apps** tab → tap **`+`** (top left) → select `PaperTerritory-unsigned.ipa`.
5. Keep your iPhone and PC/Mac on the same Wi-Fi network with AltServer running so AltStore automatically refreshes the 7-day signature before expiration.
