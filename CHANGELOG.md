# v0.1.0
## Add Bestiary UI, update .gitignore, bump version
- Add BestiaryTrackerUI.lua implementing a scrollable Bestiary UI (CreateBestiaryUI) that converts BestiaryKillsDB into a sorted list, renders rows via WowScrollBoxList, and exposes a /bt display slash command.
- Update BestiaryTracker.toc to include the new UI file and bump the addon version to 0.1.0.
- Extend .gitignore to exclude .gitattributes, LICENSE, README.md, and .vscode/*.

# v0.1.1
## Improve unit ID handling, UI & slash command
- Parse tooltip GUIDs safely to obtain NPC IDs (pcall + strsplit) in GetUnitInfo to avoid Midnight/12.0 GUID issues; adjust initialization print.
- Update slash command (/bt) to accept "display" which calls addonTable.CreateBestiaryUI(), and improve fallback target reporting.
- Refactor UI: expose CreateBestiaryUI on addonTable (toggle behavior), guard against nil DB, sort and prepare data, and initialize the modern ScrollBox rows. Update TOC ordering and rename the UI file reference (BestiaryTrackerUI.lua -> BestiaryUI.toc / BestiaryUI.lua entry in the .toc).