# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versions follow major.minor.hotfix (e.g. 1.2.3).

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
