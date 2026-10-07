# Rift Runners

An original Roblox collection-and-extraction prototype built with Luau and Rojo 7.7.1. All in-game text is English.

## Getting Started
To build the place from scratch, use:

```bash
  rojo build -o "RiftRunners.rbxlx"
```

To sync the source into Roblox Studio, run `rojo serve` from this folder and connect the Rojo Studio plugin to the displayed local address.

```bash
rojo serve
```

## Current slice

- Procedural alien home portal, four colored rift gardens, wayfinder trails, and glowstone outcrops.
- 12 original collectible Riftlings across five rarity tiers.
- 150-second runs, a six-creature satchel, one featured Epic, and a pursuing Warden.
- Safe extraction banks creatures into the persistent collection and adds coins; a field guide tracks all 12 discoveries.
- End-of-run recap reports secured finds, lost finds, and coins earned; server checks pickups, bag limits, and portal distance.
- English responsive HUD, field guide, end-of-run recap, and in-server Coins/Critters leaderboard.

DataStore persistence needs a published Roblox experience and API access enabled. The prototype has not been published; test in Studio first. See [GAME_DESIGN.md](GAME_DESIGN.md) for design decisions and remaining ship gates.
