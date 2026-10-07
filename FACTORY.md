# Viral Game Factory

This repository is the reusable foundation for rapidly producing original Roblox games.

## Production loop

1. Pick a simple, trend-inspired core mechanic.
2. Change the fantasy, progression, economy, visuals and naming so the result is original.
3. Configure the game in `src/shared/Config.luau`.
4. Build gameplay as isolated services/systems.
5. Test in Roblox Studio through Rojo.
6. Iterate from playtest data.
7. Duplicate the template for the next game.

## Architecture

- `src/shared` — configuration and shared modules
- `src/server` — authoritative game logic
- `src/client` — UI/input/feedback
- `src/server/Services` — reusable server services

The factory should optimize for fast iteration, clean separation of systems, and reusable modules rather than copying another game's content.