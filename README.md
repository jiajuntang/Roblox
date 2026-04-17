# Roblox

A chaos weather/events sandbox starring Guin Guin (Marky Penguin).

## Contents

- `src/ServerScriptService/CharacterBootstrap.server.luau` — spawn setup (walk speed, jump), unanchors character, anchors workspace, strips scripts matching known exploit strings.
- `src/ServerScriptService/WeatherSystem.server.luau` — rolls a random event every 60s (Sonic Mode / Hacker / Snow Storm / Sand Storm / Penguin Event / Chaos Sword), runs it for 120s, then resets.

## Syncing to Roblox Studio with Rojo

1. Install the Rojo CLI:
   ```sh
   brew install rojo
   ```
   (Other platforms: see https://rojo.space/docs/v7/getting-started/installation/)

2. Install the **Rojo** plugin inside Roblox Studio (Toolbox → Plugins → search "Rojo").

3. From this directory, start the sync server:
   ```sh
   rojo serve
   ```

4. In Studio, open the Rojo plugin panel → **Connect**.

Any edits you make to files under `src/` will sync into the running Studio session. Scripts under `src/ServerScriptService/` land in `ServerScriptService` in the DataModel.

## File naming convention

Rojo treats suffixes specially:

- `*.server.luau` → `Script` (server-side)
- `*.client.luau` → `LocalScript`
- `*.luau` → `ModuleScript`
