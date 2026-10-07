# Viral Game Factory

This repository is the reusable foundation for building original Roblox games quickly. **Nightshift Salvage** is the first production pilot.

## Production loop

1. Read Roblox's current charts and identify an audience need or proven mechanic.
2. Create a distinct theme, objective, map, progression, and visual identity around that signal.
3. Configure shared systems in `src/shared` and build game-specific systems as isolated server services.
4. Sync with Rojo and test the complete player loop in Roblox Studio.
5. Fix blockers, then prepare the experience page, icon, thumbnail, age questionnaire, and publish checklist.
6. Release a small first version, measure player behavior, and iterate before investing in more content.

## Architecture

- `src/shared` — configuration and shared modules
- `src/server` — authoritative game logic and player data
- `src/client` — interface, input, and moment-to-moment feedback
- `src/server/Services` — reusable server systems

Each new game should preserve the useful core and replace its theme-specific game loop, map, and content. Never copy a trending game's name, map, characters, artwork, or distinctive content.
