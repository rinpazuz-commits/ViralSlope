# Rift Runners — MVP brief

## Player promise

Run into a glowing alien wilderness, find original creatures with visible rarity, and make it back to the home portal before the rift closes. Every creature in your satchel is at risk until you return.

## Core loop

1. Spawn at the home portal and read the one-line objective.
2. Explore four colored rift gardens, glowstone formations, and collect up to six Riftlings.
3. The Warden wakes after the first creature is picked up and chases players carrying finds.
4. Return to the home portal to permanently add creatures to the collection and convert their value into Coins.
5. Spend earned Coins at the Rift Relic Atelier on cosmetic-only headgear, a stardust trail, or a companion.
6. Open the field guide, review the run recap, compare the leaderboard, then enter again.

## Product choices

- English-only UI and world copy for the first release.
- Original creature names and simple silhouettes; no existing meme characters, borrowed game art, or cloned base-stealing layout.
- Creatures are earned by playing. There are no paid random rolls or paid survival advantages in the MVP.
- Schema v3 preserves v2 progression and adds owned/equipped cosmetic state. Collection, Coins, extraction count, and leaderboard use DataStore when published with API access enabled. Studio currently falls back to `SESSION_ONLY`.
- The Atelier offers Aurora Crown (450 Coins), Stardust Wake (850 Coins), and Pocket Riftling (1,600 Coins). The server validates purchases/equips; cosmetics provide no gameplay advantage.
- The game remains playable solo, so a quiet server is not an empty round.

## Prototype balance targets

- First creature is a low-risk Common close to the portal.
- A featured Epic is present each run, far enough away to require a decision.
- Bag limit: 6. Carrying more slows the player slightly.
- The Warden gives a warning and a short grace period, then approaches the nearest player carrying creatures. Players with a light bag can outrun it; a full satchel slows them enough for the Warden to catch up.
- Runs last 150 seconds, with a 12-second home break.

## Ship gates

- Verify collection and banking with more than one player; verify simultaneous pickup cannot duplicate a creature.
- Playtest cosmetic purchases with enough/insufficient Coins, equip/unequip, respawn visuals, and persistence after rejoin.
- Play several full runs after the first successful extraction and tune the Warden from observed extraction rates.
- Check keyboard, touch controls, HUD readability, and performance on a modest phone.
- Test DataStore load, autosave, leave, rejoin, failure handling, and server shutdown after publishing to a private test universe.
- Improve the procedural cosmetics with final art and sound; create a proper icon, thumbnails, age questionnaire, and localized metadata. Consider monetization only after the core loop earns repeat plays.

## Reality check

Current chart positions show demand, not a forecast for a new game. The prototype is not yet evidence of retention or revenue. The first test should measure whether players voluntarily start a second run, then whether they return on another day.
