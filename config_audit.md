# Config Audit Notes

## Duplicate entries / conflicts
- No direct duplicate cvar assignments were found inside `empire.cfg`, `default_mp.cfg`, `r_ctf.cfg`, or `r_thedarkside.cfg` when scanning for repeated `set/seta/sets` keys.
- `default_mp.cfg` and `empire.cfg` intentionally disagree on many gameplay cvars (for example `scr_battlerank`, `scr_friendlyfire`, and multiple gametype limits). In normal server startup, `empire.cfg` should win because it is the active server config and it explicitly executes `r_thedarkside.cfg` for map rotations.
- `r_ctf.cfg` appears present but not currently executed from `empire.cfg`.

## Battle rank handling alignment
- `scr_battlerank` is the runtime switch read by gametype scripts; if set to `0` it disables battle rank logic/HUD updates.
- `_rank_gmi.gsc` reads rank thresholds and ammo values from `awe_br*` cvars through `getConfigInt`, but only if battle rank is enabled by `scr_battlerank`.
- Potential mismatch: config uses `awe_br*_satchelcharge`, while script expects `awe_br*_satchels`. Because of this key mismatch, satchel values from `empire.cfg` are not consumed and script fallbacks are used.
- Additional override risk: rPAM BO3 scripts set `scr_battlerank=1` and `scr_rank_ppr=10`; if those scripts run in a mode, they override `empire.cfg` rank cvars.
