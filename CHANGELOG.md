# v0.1.0
## WA-3 Add Bestiary UI, update .gitignore, bump version
- Add BestiaryTrackerUI.lua implementing a scrollable Bestiary UI (CreateBestiaryUI) that converts BestiaryKillsDB into a sorted list, renders rows via WowScrollBoxList, and exposes a /bt display slash command.
- Update BestiaryTracker.toc to include the new UI file and bump the addon version to 0.1.0.
- Extend .gitignore to exclude .gitattributes, LICENSE, README.md, and .vscode/*.