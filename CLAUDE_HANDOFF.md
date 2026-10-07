# Rift Runners — Claude handoff

This file is the live handoff for the user's Roblox game project. Read it first when continuing work, then inspect the current source and `git status`; this document can lag behind code.

## Goal and collaboration

The user has explicitly given Codex and Claude carte blanche to keep developing the game as a team. Keep the project moving without asking for routine implementation approval. The user's goal is an original, polished Roblox game with real replay value and eventual revenue. Do not overstate readiness, retention, earnings, or testing. Do not publish publicly or accept legal terms on the user's behalf; stop at those account-owner gates.

## Project

- Local repo: `/Users/apolon/Roblox/ViralSlope`
- GitHub: `https://github.com/rinpazuz-commits/ViralSlope`
- Main branch; implementation checkpoint: inspect `git log -1` for the latest commit. The current working tree includes an extraction burst that still needs a real in-game bank test.
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
- Atomic session lease is in the current source: acquire through `UpdateAsync`, renew on the 90-second autosave (180-second expiry), verify the token before every save, and release on player leave/server shutdown. Studio failure falls back to non-saving defaults with a warning; published servers refuse to load a profile if they cannot acquire its lock.
- Rift Relic Atelier has three earned-Coin cosmetics: Aurora Crown (450), Stardust Wake (850), Pocket Riftling (1,600). `CosmeticService` validates/applies effects server-side; `CosmeticShop.client` supplies the responsive UI. The hub includes a 3D showcase and proximity prompt.
- Successful extraction now spawns a brief radial burst of colored neon sparks based on the banked Riftlings (`RiftService.playExtractionBurst`). The Rojo build succeeds with this change; the effect has not yet been triggered and visually checked in a playtest.
- The expedition HUD computes a direction arrow and distance to the nearest replicated Riftling; with a nonempty satchel it points to the portal and prompts the player to bank when inside its safe radius. It stays client-side and has a one-second fallback refresh; now it also refreshes immediately when a replicated pickup is removed. The event-driven update compiles into an RBXLX with Rojo, but still needs a player-mode Studio check.
- The nearest-target scan reads the current replicated `WildRiftlings` folder. The server marks a pickup claimed and destroys its model after the first valid pickup, so other clients should drop that target on `ChildRemoved`. All players can still be guided toward the same contested pickup before it is claimed; verify this in a multi-client session. Claude also recommends checking whether permanent direction guidance reduces exploration, whether the bank reminder competes with Warden alerts, and mobile readability. Do not remove or weaken the guidance without playtest evidence.
- Last polish fixed a duplicate-species pickup deleting the wrong model, bag-full touch incorrectly claiming a creature, mobile HUD sizing, and multiple banks incrementing the expedition count more than once per run.

## Verified and unverified

- `rojo build -o /private/tmp/RiftRunners.rbxlx` and `git diff --check` succeeded after adding the navigation guidance.
- Roblox Studio playtest confirmed the English HUD, cosmetic shop with all three prices, and the insufficient-Coins response at a 0 balance. Restarted Studio on the latest source; the game and portal loaded. Nameplates were reduced in size and view distance after overlap was observed.
- Studio playtest after the session-lock change still starts and displays the intended `SAVE UNAVAILABLE` notice because Studio cannot access the live profile. This confirms the session-only fallback path, not the lock or durable saves.
- Not yet verified: navigation guidance in a player-mode Studio session, extraction burst appearance in a real bank, successful purchase/equip/unequip/respawn visuals, several full rounds, death/full-bag/Warden balance under real play, multi-client concurrency, actual mobile touch UI, phone performance, DataStore persistence across sessions, or player retention. Do not say those are tested.
- Previous Claude reviews were based on descriptions, not direct inspection of the running game/current code. Main useful feedback: close the coin progression loop, validate risk cases, improve visual/audio identity, and test DataStore/authority.

## Active next milestone

Safely validate the navigation guidance, extraction burst, and cosmetic purchase/equip/unequip/respawn loop in Roblox Studio. An old Command Bar draft containing a coin-grant expression is visible in the current Studio window; do not execute it. Avoid editing Studio scripts manually. Then continue audio/visual polish, test multiple players and mobile readability, and verify session locking and persistence in a private published test universe.

Claude reviewed the architecture and the reported Studio checks, but its normal desktop chat cannot read this local repo. It confirmed the unverified gates: successful purchase across restart, respawn cosmetics, migration with real v2 data, and durable DataStore behavior. It recommends using a separate private test universe/DataStore, then testing session-lock reacquisition, fast repeat purchases, insufficient balance, non-owned equip attempts, and cosmetic cleanup/reapply through respawn. For source review, paste `PlayerDataService.luau`, `CosmeticService.luau`, `CosmeticShop.client.luau`, and `CosmeticCatalog.luau` into Claude or use Claude Code against this repo. Inspect `git status` and this handoff before edits, and coordinate overlapping writes. Its navigation review additionally called out shared targets before pickup, the risk of removing exploration with constant guidance, alert overlap, and mobile readability; see the implementation note above.

Claude's latest product review says to prioritize the real private DataStore/migration checks, then observe 5–10 outside players (including mobile) to see whether they voluntarily start a second run, then decide whether the loop needs changes or merits more content/polish. It cannot read this local handoff in its regular chat, so its review used only the status message. A Studio attempt to play through collection/extraction is still inconclusive; no successful pickup/bank or extraction-burst visual has been confirmed.

## Remaining release gates

1. Playtest the extraction burst and earned-coin cosmetic loop.
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
