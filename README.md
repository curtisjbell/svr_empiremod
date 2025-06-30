# Empire CTF Server Config

This repository contains configuration files and assets for the Empire CTF server running Call of Duty: United Offensive.  
The primary server configuration is provided in `empire.cfg`. Copy this file to your server and execute it from the game console or include it in your startup scripts.

## Key Features
- Custom server branding using `awe_server_logo_text` and related cvars.
- Extensive AWE mod settings for gameplay tweaks and voting.
- Default game and weapon limits tailored for Capture the Flag play.

For additional notes on mod changes see `the_empire_mod.txt`.

## Changelog

- **v1.03** - Added map rotation history to improve map voting.
- **v1.02** - Added reload glitch detection with new cvars for AWE.
- **v1.01** - Fixed display bug when notifying players about AFK status.
- **v1.0** - Initial release with branding, AutoAdmin messages and gametype voting.
