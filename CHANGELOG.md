# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versions follow major.minor.hotfix (e.g. 1.2.3).

## [2.0.0] - 2026-07-13

### Changed
- **Breaking: split into three addons.** The custom talent tree window (grid, connections,
  tier-lock, Plan Mode, everything in the old `Talents/` folder except the talent *data service*)
  moved out into its own new addon, **TeronModernTalents**. The shared class/OOP framework, icon
  widget base class, and UI factories moved out into a new required dependency, **TeronModernCore**
  - both this addon and TeronModernTalents build on it instead of TeronModernTalents depending on
  this addon directly, so either can be installed independently of the other.
- This addon now requires **TeronModernCore** to be installed alongside it (`## Dependencies` in
  the `.toc`). **TeronModernTalents** is an optional companion (`## OptionalDeps`) - `/msb talents`
  gracefully does nothing if it isn't installed.
- TeronModernTalents now uses its own dedicated `ModernTalents_DB` SavedVariable instead of
  sharing `ModernSpellBook_DB`. This is a clean break, not a migration - existing talent
  settings/plans will need to be recreated after upgrading if TeronModernTalents is installed.
- `/msb reset` no longer preserves talent-plan data (it never lived in this addon's SavedVariable
  to begin with, once TeronModernTalents is installed).

## [1.7.0] - 2026-07-13

### Added
- Talent frame: **Plan Mode**, a "Learned"/"Planned" toggle near the header that lets you assign
  virtual talent points independent of your real ones - the entire grid (connection lines,
  tier-lock indicator, grid-line coloring, icon lock/available/partial/maxed states) simulates
  what your build would look like from the virtual totals when Planned is active, without ever
  spending a real point. Left-click adds a virtual point, right-click removes one; removals that
  would orphan a dependent talent or break another planned talent's tier requirement are blocked
  with a chat explanation instead of silently corrupting the plan. The real rank (bottom-right on
  each icon) never changes in Planned mode; a new cyan planned-rank badge (bottom-left) shows
  whenever a talent has a virtual point, in either mode.
- Talent frame: up to **20 named plans** per character, switchable, renameable, and clearable from
  the settings gear's new "Talent Plans" submenu.
- Talent frame: **"Force shift-click learn"** option (settings gear) - when enabled, spending a
  real talent point requires holding Shift, as misclick protection. Only applies to real spending;
  Plan Mode is never gated by it, and has no Shift-click exception of its own - there is no way to
  spend a real point from Planned mode.

## [1.6.6] - 2026-07-11

### Fixed
- Found the actual root cause of the persistent grid-hiding bug: `ForceLoad()` (which opens and
  closes the real `SpellBookFrame` twice on every login/reload to prime Blizzard's spell-data
  cache) calls Blizzard's own `ShowUIPanel`/`HideUIPanel` - and that native panel-layout code, not
  anything this addon's own grid logic ever did, hides the default action bars' empty-slot grid as
  a side effect. Nothing ever reasserted it afterward, which is why it stayed gone permanently
  until the addon was disabled entirely (confirmed via bisection testing), regardless of whether
  this addon had any grid-handling code of its own (1.6.3/1.6.5 removed it entirely; the bug
  persisted both times). Fixed with a single, one-time re-show call right after `ForceLoad`'s
  toggle sequence settles - deliberately not tied to any recurring event this time, unlike 1.6.4's
  reactive approach, which caused a feedback loop severe enough to break the spellbook keybind.

## [1.6.5] - 2026-07-11

### Removed
- **Reverted 1.6.4 entirely** - it broke the default spellbook keybind (the UI stopped opening).
  Suspected cause: `ActionButton_ShowGrid` likely triggers its own action-bar refresh, which can
  re-fire `ACTIONBAR_PAGE_CHANGED`/`UPDATE_BONUS_ACTIONBAR` - the exact two events 1.6.4 reacted to
  by re-calling `ActionButton_ShowGrid` on all 48 multi-bar buttons, a plausible tight feedback
  loop severe enough to make the client stop responding to keybinds. Not confirmed with certainty
  (no live client access to verify directly), but the risk of leaving it live while it blocks basic
  addon functionality outweighed chasing the always-on-grid feature further right now. Back to
  1.6.3's baseline: this addon does not touch action-bar grid visibility at all.

## [1.6.4] - 2026-07-11

### Added
- Re-added `MSB_ActionBar.lua`, redesigned as a brute-force "always show" enforcer rather than a
  precise show/hide-on-open/close manager: 1.6.3 removed grid handling entirely on the theory that
  the client's native "Always Show Buttons" setting should be left alone to govern it, but the
  grid kept disappearing even with zero grid-touching code left in this addon - confirming some
  other trigger (most likely Blizzard's own panel-layout code, which runs whenever any UI panel
  opens) hides it independently of anything this addon does. Rather than keep chasing that, this
  now just re-shows the grid immediately on `PLAYER_ENTERING_WORLD`, `ACTIONBAR_HIDEGRID`,
  `ACTIONBAR_PAGE_CHANGED`, and `UPDATE_BONUS_ACTIONBAR`, regardless of what caused it to hide.

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
