# Rift Runners — MVP brief

## Player promise

Run into a glowing alien wilderness, find original creatures with visible rarity, and make it back to the home portal before the rift closes. Every creature in your satchel is at risk until you return.

## Core loop

1. Spawn at the home portal and read the one-line objective.
2. Explore four colored rift gardens, glowstone formations, and collect up to six Riftlings.
3. The Warden wakes after the first creature is picked up and chases players carrying finds.
4. Return to the home portal to permanently add creatures to the collection and convert their value into coins.
5. Open the field guide to see discovered species, review the run recap, compare the Coins and Critters leaderboard, then enter again.

## Product choices

- English-only UI and world copy for the first release.
- Original creature names and simple silhouettes; no existing meme characters, borrowed game art, or cloned base-stealing layout.
- Creatures are earned by playing. There are no paid random rolls or paid survival advantages in the MVP.
- Collection, coins, extraction count, and leaderboard are saved through DataStore when the experience is published and API access is enabled.
- The game remains playable solo, so a quiet server is not an empty round.

## Prototype balance targets

- First creature is a low-risk Common close to the portal.
- A featured Epic is present each run, far enough away to require a decision.
- Bag limit: 6. Carrying more slows the player slightly.
- The Warden gives a warning and a short grace period, then approaches the nearest player carrying creatures. Players with a light bag can outrun it; a full satchel slows them enough for the Warden to catch up.
- Runs last 150 seconds, with a 12-second home break.

## Ship gates

- Verify collection and banking with more than one player; verify simultaneous pickup cannot duplicate a creature.
- Play several full runs after the first successful extraction and tune the Warden from observed extraction rates.
- Check keyboard, touch controls, HUD readability, and performance on a modest phone.
- Test DataStore load, autosave, leave, rejoin, failure handling, and server shutdown after publishing to a private test universe.
- Add a proper icon, thumbnails, sound, final art, age questionnaire, localized metadata, and monetization only after the core loop earns repeat plays.

## Reality check

Current chart positions show demand, not a forecast for a new game. The prototype is not yet evidence of retention or revenue. The first test should measure whether players voluntarily start a second run, then whether they return on another day.
