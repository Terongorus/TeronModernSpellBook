# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versions follow major.minor.hotfix (e.g. 1.2.3).

## [1.6.3] - 2026-07-11

### Removed
- `ActionBarHelper` and all action-bar grid management removed entirely. The 1.6.2 fix improved
  its reference counting, but live stack-trace diagnostics showed the real problem was deeper:
  even a perfectly paired show-then-hide cycle (triggered via a third-party addon hook chain
  through the real `SpellBookFrame`) still left the default action bars' empty-slot grid hidden
  afterward, because hiding it doesn't know or care what the grid's state was before this addon
  ever touched it. Rather than try to precisely detect and restore that pre-existing state, this
  addon now leaves action-bar grid visibility alone entirely - it's governed solely by the
  client's own native "Always Show Buttons" setting, same as it would be without this addon
  installed at all.

## [1.6.2] - 2026-07-11

### Fixed
- `ActionBarHelper`'s per-button grid show/hide reference count never actually worked - it tried
  tracking a count via `button:GetAttribute`/`SetAttribute`, the secure-template attribute API,
  which doesn't exist in vanilla 1.12.1 (added in TBC). That check silently never ran, so every
  call forwarded 1:1 to Blizzard's `ActionButton_ShowGrid`/`HideGrid` with no real counting -
  meaning any unpaired `HideAllGrids()` call could unconditionally hide the empty-slot grid on the
  default action bars even when something else (e.g. the "Always Show Buttons" setting) had its
  own reason to keep it visible. Replaced with a real Lua-table-based counter; `HideButtonGrid` now
  refuses to hide a button it never contributed a matching show for.

### Changed
- Consolidated a redundant `OnHide` handler on the spellbook frame: `MSB_Settings.lua`'s
  `CSettingsMenu` constructor was silently overwriting the one `MSB_Spellbook.lua` set up moments
  earlier (`SetScript` replaces, not stacks), leaving dead code with a misleading comment. Now
  there's one clearly-documented, authoritative handler.

## [1.6.1] - 2026-07-10

### Fixed
- Asset textures (spellbook backgrounds, talent icons/backgrounds, connection arrows,
  section separators, etc.) were still pointing at the old `Interface\AddOns\
  ModernSpellBook\Assets\...` path from before the addon's folder was renamed to
  `TeronModernSpellBook`, so none of them loaded. Updated every hardcoded asset path
  across `Spellbook/` and `Talents/` to the current folder name.

## [1.6.0] - 2026-07-10

### Added
- Native "What's Training" tab support for the companion addon
  **TeronWhatsTraining**: when it's installed and loaded, it registers its own tab
  inside this spellbook instead of overlaying the default Blizzard spellbook.

### Changed
- Dropped the `-TW` suffix from the version number — this addon has never been
  Turtle-WoW-exclusive, and the suffix no longer reflected that.
- `SetShape`'s legacy WhatsTraining overlay-detection code now guards on the old WT
  UI's Blizzard frame actually existing, instead of assuming it always does, so it no
  longer conflicts with the new tab-based WhatsTraining integration.
- Tab label padding increased slightly (`CTab:SetName`) so longer tab names (e.g.
  "What's Training") get more visual breathing room.

### Fixed
- Page counter ("Page X / Y") was silently dropping the max-page count on some
  clients, because it depended on a Blizzard global string
  (`PRODUCT_CHOICE_PAGE_NUMBER`) that isn't consistently defined the same way across
  clients. Replaced with a literal format string.
- The action-bar "empty slot" grid overlay (`ActionBarHelper:ShowAllGrids`) was shown
  on every spellbook open but never torn down on close, since nothing balanced it with
  `HideAllGrids`. Added the missing `OnHide` handler.
- `SOUNDKIT` polyfill could silently lose keys when another addon (e.g.
  TeronWhatsTraining) also polyfills the same global with a different partial key set
  and loads first — changed to merge keys individually instead of an all-or-nothing
  guard.
