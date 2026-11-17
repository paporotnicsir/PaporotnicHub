PAPOROTNIC HUB — Universal Launcher v0.1.0 (prototype)

GitHub repo: https://github.com/paporotnicsir/PaporotnicHub

1. Upload launcher.lua and catalog.json to the repository root, keeping hub.lua unchanged.
2. Execute loader.lua via your Roblox executor.
3. The launcher shows Home and Games tabs and checks exact game.PlaceId.
   Disassemble Car Tycoon: 89472775643845.
4. Add another game by adding one object in catalog.json.games with:
   id, title, description, version, placeIds, universeId, enabled, script.
   Scripts must be hosted under the same raw.githubusercontent.com repo path.
5. Latest-version, announcements, and lifetime price are catalog.json fields.
6. Current catalog.auth.mode is "public" (test/open access, NOT key security).
   For a real key system, deploy an HTTPS verification service and configure
   catalog.auth.mode = "server" and catalog.auth.verifyUrl.
   The backend must answer JSON {"valid":true} on successful POST with {"key":"..."}.
   This is an integration interface only, NOT a secure completed licensing solution.
7. Public GitHub game modules can always be launched directly, bypassing client gates.
   Client-side scripts and keys cannot be fully protected from extraction.
8. F7 toggles universal launcher, F6 stays with per-game hub.

This scaffold was syntax-inspected but cannot be tested inside a Roblox experience here.
