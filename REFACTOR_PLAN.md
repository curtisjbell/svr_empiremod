# empire_mod refactor & PAM removal plan

## Goals
- Remove PAM functionality entirely.
- Preserve and harden core EMPIRE-derived systems required by empire_mod:
  - AFK player detection.
  - Next-map selection logic (non-GUI, algorithmic, rotation + player count + gametype weighting aware).
  - Rank tuning.
- Rebrand runtime/UI/config branding from EMPIRE/PAM to empire_mod.
- Prioritize reliability on legacy CoD engine scripting constraints.

## Legacy-engine constraints (must-follow)
- Do not introduce operators/functions that are not already present in this codebase.
- Prefer existing helper patterns (e.g., `cvardef`, `getcvar*`, `setcvar`, array loops).
- Keep thread lifecycle explicit (`endon`/`notify`) and avoid over-threading.
- Avoid adding fragile implicit behavior; prefer explicit cvar gates and defaults.

## Current dependency map (high-level)

### 1) Core orchestrator
- `maps/MP/gametypes/_awe.gsc` is the central integration point:
  - boots feature cvars,
  - wires callbacks,
  - calls mapvote/rotation history helpers,
  - contains or triggers camping-derived behavior that was customized for AFK.

### 2) Next-map logic (currently in mapvote module)
- `maps/MP/gametypes/legacy mapvote module.gsc` currently contains both:
  - old map-vote HUD/UI flow, and
  - customized algorithmic next-map selection logic using cvars such as:
    - `empire_random_gametype_weights`
    - `empire_gametype_weight_*`
    - `empire_map_history*`
    - `empire_gametype_history*`
    - `empire_gametype_playercount_limits`
- `_awe.gsc` calls history update methods from this file at startup.
- This should be split so algorithmic selection is isolated from GUI vote remnants.

### 3) Rank tuning
- `maps/MP/gametypes/_rank_gmi.gsc` contains battle-rank tuning and ammo profile cvars (`empire_br*`).
- Appears independent of PAM; should be retained and only lightly renamed/aliased where safe.

### 4) PAM footprint
- PAM scripts still exist in tree (`_pam_sd.gsc`, `_pam_*`) and PAM cvars remain in config (`empire.cfg`).
- SD was reportedly reset to EMPIRE implementation, but repository still contains PAM artifacts.
- Risk: orphan references from shared utility/config paths and leftover cvar state.

## Refactor strategy (phased)

### Phase 0: Safety baseline
1. Snapshot all PAM references and all mapvote references.
2. Identify runtime entrypoints that still call PAM scripts.
3. Add a temporary compatibility report log (dev-only) for unresolved cvars.

Deliverable: dependency matrix (caller -> callee -> cvars -> gametype scope).

### Phase 1: Extract next-map engine from mapvote module
1. Create a new module (recommended): `maps/MP/gametypes/_empire_nextmap.gsc`.
2. Move only non-UI algorithmic functions from `legacy mapvote module.gsc` into this module:
   - candidate pool construction,
   - player-count limits,
   - gametype weighting adjustments,
   - map/gametype history penalties.
3. Keep public wrapper names stable initially (shim in `legacy mapvote module.gsc`) to avoid breakage.
4. Remove/disable vote HUD flow from startup path.

Deliverable: deterministic next-map selector with same current output given same cvars/history.

### Phase 2: AFK subsystem hardening + cvar gating
1. Locate AFK logic currently tied to camping-detection lineage in `_awe.gsc`.
2. Introduce explicit gate cvar:
   - `empire_afk_detection` (0/1; default 1).
3. Wrap AFK threads/checkers so they no-op when disabled.
4. Ensure disable path cleans HUD/state and terminates related threads.

Deliverable: AFK feature independently togglable without affecting other anti-camp logic.

### Phase 3: PAM removal
1. Remove PAM script includes/calls from active gametype paths.
2. Remove PAM-specific runtime cvars from default server config (`empire.cfg`) or move to legacy archive section.
3. Keep deleted functionality out of startup paths; avoid dead references.
4. Optionally archive PAM files under `legacy/pam/` before deletion (for rollback clarity).

Deliverable: no active script path depends on PAM.

### Phase 4: Rebrand EMPIRE -> empire_mod (safe subset)
1. Replace player-facing branding strings first (HUD text, log strings, menu labels).
2. Keep internal identifiers stable where renaming is high-risk (e.g., function names) unless wrappers are added.
3. Replace hardcoded brand text in configs/docs/scripts with `empire_mod` equivalents.

Deliverable: runtime branding shows empire_mod; no hardcoded EMPIRE/PAM player-facing text.

### Phase 5: Reliability cleanup
1. Normalize cvar read/write points (single owner per subsystem where possible).
2. Add guard clauses around nullable player/entity references in threaded loops.
3. Reduce duplicate history/parsing code by central helper functions.

Deliverable: fewer side effects, cleaner ownership, easier future maintenance.

## Test plan (per phase)
- Boot test by gametype (`dm`, `tdm`, `ctf`, `hq`, `sd`) for script errors.
- Next-map determinism tests:
  - fixed rotation + fixed history + fixed player count => expected map/gametype.
- AFK gate tests:
  - `empire_afk_detection 0`: no AFK punish/kick/warn behavior.
  - `empire_afk_detection 1`: existing AFK behavior preserved.
- Config migration tests:
  - no PAM cvar required for successful startup.

## Risks and mitigations
- Risk: hidden PAM coupling in shared utility/config pathways.
  - Mitigation: perform caller graph and startup trace before deletion.
- Risk: next-map regressions from mapvote extraction.
  - Mitigation: keep shim wrappers + deterministic comparison tests.
- Risk: legacy engine quirks with renamed files/functions.
  - Mitigation: introduce wrappers first, then optional deeper rename later.

## Naming and compatibility policy
- Use `empire_*` for new cvars/modules.
- Keep legacy `empire_*` cvars readable during migration (alias/fallback) where practical.
- Prefer additive migration (new name + fallback read) before removing old names.

## Implementation checklist against requested outcomes
- [ ] PAM functionality removed from active runtime paths.
- [ ] AFK detection preserved and controlled by enable/disable cvar.
- [ ] Next-map logic preserved (rotation + player count + gametype weights/cvars/history).
- [ ] Rank tuning preserved.
- [ ] Rebrand to empire_mod.
- [ ] Hardcoded EMPIRE/PAM branding removed from player-facing paths.

