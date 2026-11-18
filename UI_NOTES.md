# UI Notes — Paper Territory (iOS)

Reference notes compiled from visual inspection of `../paper.io adr/reference_screens/`, `../paper.io adr/img/`, `../paper.io adr/audit_comparisons/`, and `../paper.io adr/src/ui/theme.ts`.

> **Brand & Asset Compliance:** All brand names (`Paper.io`, `Voodoo`) and copyrighted character likenesses seen in reference captures are excluded. Our game is titled **Paper Territory**, all visible copy is strictly **English**, and 100% of graphics, skins, icons, and audio are generated in code.

---

## 1. Visual Design System & Color Tokens

- **Typography:** Bold rounded display typeface (`SF Pro Rounded` / `.rounded` system bold/black weights) with crisp dark-navy (`#071A75` / `#081B5B`) strokes or subtle drop shadows on headers and badges.
- **Corner Radius & Paper Tactility:** Generous rounded corners (`14pt`–`24pt` on cards, full capsules for HUD pills), multi-layer glossy gradients, crisp `2pt`–`3pt` borders, and soft downward 2.5D bevels/drop shadows giving a tactile "cut paper & toy block" feel.
- **Core Palette (sampled from reference frames):**
  - **Lobby Sky Background:** `#0091FE` (top) → `#21CAFD` (mid) with radial cyan center glow `#4DF3E0` and subtle world continent silhouette watermark (`opacity ~0.10`).
  - **Top HUD Pills:** Deep navy `#102B9D` fill with `#071A75` stroke, coin gold `#FFE804` / `#FFC400`, gem magenta `#F77BFC`, green plus action badge `#5CE61C` (`#1D7306` stroke).
  - **Primary Play CTA:** Bright yellow-gold gradient `#FFF35A` → `#FFE804` → `#FFC400`, thick white/navy rim, bold play triangle.
  - **Bottom Nav Bar:** Soft sky paper strip `#E3F1FE` → `#D1E6FC` with curved `#1665D8` top border wave and central circular Play/Home button rising above the bar.
  - **Arena Paper Floor:** Pastel mint `#EBF7F0` / `#E2FBEF` with subtle dot/grid pattern (`rgba(128, 203, 196, 0.24)`), crisp `#80CBC4` arena border, and `#CFD8DC` exterior paper drop-off.

---

## 2. Screen-by-Screen Layout & Component Breakdown

### 2.1 Splash / Loading Screen
- **Layout:** Vertical sky gradient (`#0480EC` → `#1DAEFB`) with bright cyan center halo (`#01FDFC`), tilted bold 3D title (**Paper Territory**) in the upper third (`y ~12–28%`), floating original block mascots with colored trails in the middle, warm amber-gold paper hill at the bottom (`#FDA600` → `#FCAE01`), and a translucent loading ring (`y ~91%`).

### 2.2 Home Screen
- **Top Bar:** Circular player avatar button (left), Coins pill + Gems pill (center), crisp white Settings gear button with `#071A75` stroke (right).
- **Center Showcase:** Mode/Progress capsule badge (`#000E7F` track, `#462FA6` / `#22C55E` fill) above a 2.5D floating territory island with the equipped block skin and a glowing curved trail behind it.
- **Side Floating Pills (Right):** Daily featured skin preview with timer and coat-hanger badge; simulated No-Ads offer pill below.
- **Bottom Action Wings + Play:** Left wing (`#3EBEFE` → `#199FFF`), central oversized circular Play button (`#FFE804`), right Rank wing (`#F8A254` → `#E87314`) showing current rank tier and star score.
- **Bottom Navigation (5 Tabs):** `Shop`, `Heroes`, `Home`, `Missions`, `World`.

### 2.3 In-Match Gameplay & HUD (Steps 1–3 Priority)
- **Arena Canvas (SpriteKit):**
  - Clean paper background `#EBF7F0` with subtle grid lines/dots so player speed and grid alignment read clearly.
  - Crisp outer boundary border (`#80CBC4`) with outer shadow `#CFD8DC`.
  - Territories rendered as crisp vibrant blocks with a darker bottom/side bevel (`darkColor`) and soft shadow for 2.5D paper-cut depth.
  - Trails rendered as semi-transparent ribbons (`~60%` opacity of skin base color) connecting exit cell to head.
  - Entities rendered as square/rounded-square block characters with directional eyes, subtle tilt/animation, and small clean nametag below/above.
  - **Invisible Touch Control:** Swipe/drag anywhere on the arena to queue turns; no opaque joystick circle cluttering gameplay. Keyboard arrows / WASD also supported for iPad / Simulator.
- **HUD Overlay (Minimal & Clean):**
  - **Top Center:** Territory percentage progress bar (`#1D1391` capsule track, bright progress fill, `100%` star crown milestone on the right) + live `%` label.
  - **Top Left:** Kill count capsule (skull icon + numeric kill count) + Pause button.
  - **Top Right:** Live Leaderboard Top 5 pinned to the right edge (`#1` gold badge with crown, `#2` silver, `#3` bronze, `#4`–`#5` compact pills; if human player is outside Top 5, append player rank row cleanly below a small gap).
  - **Bottom Left:** Compact square/rounded minimap showing real-time territories and player indicator.
  - **No quick-toggle clutter in gameplay:** Bot difficulty, Edge rule, and Head-on rule toggles live in Settings (not inside the match HUD).

### 2.4 Game Over & Match Summary
- **Revive / End Overlay:** Radial navy-blue backdrop (`#014FD8` → `#084587`), elimination banner (`"Eliminated by <Name>"` or reason like `"Hit your own trail"` / `"Hit the arena edge"`), bold white-on-navy `"Game Over!"` (or `"Victory!"`), optional heart revive prompt (`3 → 2 → 1` with simulated ad/gem revive), `"Play Again"` green 3D pill button, and `"Home"` / `"No, thanks"` button.

### 2.5 Shop, Heroes, Missions, World Map & Settings (Later Steps)
- **Shop:** Blue-white striped awning header, Daily Free Card, 2×2 Hero Chests (`Common`, `Rare`, `Epic`, `Legendary`), Gem packs, Coin packs with `"BEST VALUE"` / `"MOST POPULAR"` diagonal tags.
- **Heroes / Skin Gallery:** Category tabs (`Colors`, `Shapes`, `Animals`, `Flags`, `Trails`, plus `Seasonal`), 3-column grid with owned checkmarks, gem prices, and unlock progress bars; interactive 3D-style pedestal preview carousel.
- **Missions:** Purple-pink gradient (`#7F25F5` → `#FADBFC`), top `0/3` gem reward pedestal, dark blue (`#003BD2`) card frame with `Daily` (yellow active tab) and `Lifetime` tabs, countdown timer, reroll button, and progress bars.
- **World Map:** `#00ACFD` ocean with subtle wave pattern, 2.5D white/green conquered regions, pan/zoom gestures, region unlock badge top-left.
- **Settings & Parent Gate:** Sound & Haptics toggles, Bot Difficulty (`Easy` / `Normal` / `Hard`), Edge Rule (`Eliminate` / `Block`), Head-On Rule (`Larger Territory Wins` / `Both Eliminated`), plus Parent Gate (3-second hold or math challenge) guarding simulated `"Unlock All"` / purchase actions.
