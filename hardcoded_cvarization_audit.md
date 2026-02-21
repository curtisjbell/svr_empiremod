# Hardcoded Message & Config Audit

## Scope reviewed
- Script trees: `maps/**/*.gsc` and `_rPAM_rules/**/*.gsc`.
- Focus: player-facing hardcoded prints (`iprintln`/`iPrintLn` variants) and hardcoded `setCvar("...", "...")` literal values.

## High-level findings
- Large number of direct player-facing string literals are embedded in script logic (hundreds of lines).
- Highest concentration of hardcoded player messaging is in:
  - `maps/MP/gametypes/_pam_sd.gsc`
  - `maps/MP/gametypes/_pam_sd_unmodified.gsc`
  - `maps/MP/gametypes/_awe.gsc`
  - `_rPAM_rules/_rpam_messages.gsc`
- High concentration of hardcoded runtime defaults (`setCvar` literal values) is in core gametype files like `ctf.gsc`, `dom.gsc`, `bas.gsc`, and PAM SD variants.

## Concrete examples worth externalizing first
1. Demo-recording enforcement messages are hardcoded in `_pam_sd.gsc`.
   - See lines around `rDEMORECORDINFO()` where static message triplets are repeated.
2. Fastshoot/automod warning text is hardcoded in `_pam_sd.gsc`.
3. Ruleset legal text/checklist lines are hardcoded in `_rPAM_rules/_rpam_messages.gsc`.
4. Exploit warning/broadcast text is hardcoded in `maps/MP/_exploit_blocker.gsc`.

## Cvarization options
### Option A (minimal risk): message-template cvars only
- Introduce cvars for high-frequency admin/player-facing strings, with safe defaults in code if unset.
- Keep existing call sites and color codes; substitute message templates at runtime.
- Good first targets:
  - `rpam_msg_demo_1`, `rpam_msg_demo_2`, `rpam_msg_demo_3`
  - `rpam_msg_fastshoot`
  - `rpam_msg_exploit_warn_self`, `rpam_msg_exploit_warn_global`

### Option B (medium): helper API + cvar-backed catalog
- Add a helper in a shared util script (`maps/MP/gametypes/_pam_utilities.gsc` or similar):
  - `getMessageCvar(name, fallback)`
  - `broadcastMessage(name, fallback)`
- Replace direct literals in top-traffic files only.
- Reduces duplicated format/color prefix logic.

### Option C (larger): structured message namespace
- Standardize naming and ownership:
  - `msg_pam_*`, `msg_awe_*`, `msg_rpam_*`
- Centralize defaults in one file + expose key subset in `empire.cfg`.
- Best long-term maintainability, but broad touch surface.

## Recommendation
- Start with Option A in `_pam_sd.gsc`, `_rpam_messages.gsc`, and `_exploit_blocker.gsc` only.
- Defer core stock gametype defaults (`ctf.gsc`, `dom.gsc`, `bas.gsc`) because many `setCvar` literals are intended fallback guards and changing them globally has gameplay risk.
