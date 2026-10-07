# Nightshift Salvage — vertical slice

## The pitch

Players leave a beacon-lit refuge to recover strange signal shards from abandoned forest relays. They decide how long to stay: each shard increases the value in their bag, but **The Echo** tracks anyone carrying salvage. Players must return to the beacon before the 100-second expedition ends; a safe return banks the haul, while a knockout or nightfall loses it.

## Why this direction

Roblox's current charts include very large collection/stealing games, co-op survival, pet experiences, and action games. This prototype combines the broad appeal of collection and timed co-op survival with an original night-signal setting and extraction choice. It does not reuse another experience's characters, names, map, assets, or exact loop. Charts are a demand signal, not a promise of success.

## Current playable loop

1. Wait at the refuge for the next expedition.
2. Explore five abandoned relay sites and collect randomly placed signal shards.
3. Keep an eye on The Echo and the countdown.
4. Return to the beacon to bank the bag as cash.
5. Spend recovered cash in future progression updates; records and extractions are saved when DataStore access is available.

## Prototype limits

- The map and art are assembled from original primitive parts; final custom art, audio, and polish are still needed.
- Relics are shared pickups in this first version; party matchmaking, individual loot instances, upgrades, and a shop are not implemented yet.
- DataStore persistence depends on Roblox experience settings and a published universe. Studio may warn that API access is unavailable.
- Publishing, the experience icon/thumbnail, age questionnaire, monetization, analytics, and live-player testing are separate production steps.
