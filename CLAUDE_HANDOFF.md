# Rift Runners — Claude handoff

This file is the live handoff for the user's Roblox game project. Read it first when continuing work, then inspect the current source and `git status`; this document can lag behind code.

## Goal and collaboration

The user has explicitly given Codex and Claude carte blanche to keep developing the game as a team. Keep the project moving without asking for routine implementation approval. The user's goal is an original, polished Roblox game with real replay value and eventual revenue. Do not overstate readiness, retention, earnings, or testing. Do not publish publicly or accept legal terms on the user's behalf; stop at those account-owner gates.

## Project

- Local repo: `/Users/apolon/Roblox/ViralSlope`
- GitHub: `https://github.com/rinpazuz-commits/ViralSlope`
- Main branch; last known pushed commit: `b1c468d Polish Rift Runners production slice`
- Roblox Studio place tab: `Place1`; Rojo plugin was connected to `localhost:34872` in the previous session.
- All player-facing text is English.
- Game concept/name: **Rift Runners** — collect original alien creatures during a timed expedition, then extract at the portal before the Warden catches you or the rift closes.

## Current implementation

- Rojo source project with shared catalog/config, server services, and client HUD.
- Procedural central portal, four colored garden landmarks, trails, glowing rock outcrops, and 12 original Riftlings in five rarity tiers.
- 150-second expeditions, 12-second home break, 24 pickups, six-item satchel, one guaranteed Epic, Warden warning/chase/damage, risk of losing carried creatures.
- Server owns pickup, bag capacity, extraction distance, coin reward, collection updates, and run summary.
- English responsive HUD, field guide (species counts), bank/loss messages, end-of-run recap, and Coins/Critters leaderboard.
- DataStore schema v3 saves Coins, creature counts by ID, expeditions, total secured, owned cosmetics, and equipped cosmetic. The v2 migration preserves existing progression. In Studio it reports `SESSION_ONLY` until a suitable published test universe/API access is configured.
- Rift Relic Atelier has three earned-Coin cosmetics: Aurora Crown (450), Stardust Wake (850), Pocket Riftling (1,600). `CosmeticService` validates/applies effects server-side; `CosmeticShop.client` supplies the responsive UI. The hub includes a 3D showcase and proximity prompt.
- Last polish fixed a duplicate-species pickup deleting the wrong model, bag-full touch incorrectly claiming a creature, mobile HUD sizing, and multiple banks incrementing the expedition count more than once per run.

## Verified and unverified

- `rojo build -o /private/tmp/RiftRunners.rbxlx` and `git diff --check` succeeded after commit `b1c468d`.
- Roblox Studio showed the English HUD, portal, pickups, and a round starting. Earlier Studio checks verified pickup, portal banking, collection update, and coin award in the successful case.
- Not yet verified: several full rounds, death/full-bag/Warden balance under real play, multi-client concurrency, actual mobile touch UI, performance on a phone, DataStore persistence across sessions, or player retention. Do not say those are tested.
- Previous Claude reviews were based on descriptions, not direct inspection of the running game/current code. Main useful feedback: close the coin progression loop, validate risk cases, improve visual/audio identity, and test DataStore/authority.

## Active next milestone

Finish validating the cosmetic shop loop in Roblox Studio: purchase, insufficient-balance response, equip/unequip, respawn reapplication, and a fresh build/restart. Then add audio/visual polish, test multiple players and mobile readability, and address session locking/persistence before a private published test.

Claude reviewed the architecture from a summary but cannot read this local repo from its normal desktop chat. It recommended versioned migration, preserving profiles on load failure, server-owned prices/atomic debit, late-join state fetch, low-cost effects, and large mobile targets. Several are implemented; session locking and live DataStore tests remain open. For a direct review, paste `PlayerDataService.luau`, `CosmeticService.luau`, `CosmeticShop.client.luau`, and `CosmeticCatalog.luau` into Claude or use Claude Code against this repo. Inspect `git status` and this handoff before edits, and coordinate overlapping writes.

## Remaining release gates

1. Implement and playtest the earned-coin cosmetic loop.
2. Improve the world/character/item art and add original sound feedback; check device performance.
3. Test mobile and multi-player cases, then run repeated complete rounds and tune Warden difficulty.
4. Use a private test experience to validate DataStore load/save/leave/shutdown before public launch.
5. Prepare icon, thumbnails, experience metadata, age questionnaire, and a fair monetization plan only after core retention is measured.
6. The game is currently a prototype, not publicly published and not proven to earn revenue.

## Working agreement

- Keep code in the Rojo source tree; avoid manual-only Studio edits.
- Keep server authoritative for economy and item ownership.
- Preserve existing player data and original game identity.
- After meaningful changes, run `rojo build`, `git diff --check`, and an appropriate Studio check; commit/push only when the user has already authorized it (they have in this thread).
- Send concise French progress to the user. Keep this document updated so Claude can resume from the repo if the conversation changes.
