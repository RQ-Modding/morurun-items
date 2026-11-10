# Changelog

Each section is a version of the mod, the `version` in `mod.json`. The release workflow copies the
section of a tagged version into the release notes.

## 1.2.1

- Reads and writes the five slots with the loader's `rq.chara.absorbed` and `set_absorbed`, finds
  the vault's special items by the rows' `no` and `place`, and plays the equip sound with
  `rq.sound.play`, instead of the game's code by name. Nothing changes for players.
- Needs loader 2.23.0.

## 1.2.0

- The MORU RUN button is one of the status page's own buttons (`rq.gamebutton`'s `"status"` group,
  loader 2.20.0), in the same place left of the X: the game's hover frame, pressed and greyed looks,
  its tip in the game's comment window, and the arrow keys reach it (Up from the Special slot).
- The card is drawn again with `rq.statuspage.refresh()` and the character read with
  `rq.statuspage.chara()`, in place of the mod's own reads of the game; item names come from
  `rq.item.info`, so other mods' `rq.item.on_create` no longer see the mod's lookups.
- For agents: the button is the control `morurun-items.open` (was `button-morurun`).

## 1.1.0

- The Yes/No questions and the notices are the loader's `rq.ui.confirm` and `rq.ui.notice`
  (loader 2.19.0) instead of the game's dialog functions by name. They look the same, and an item
  name with `@` in it no longer breaks the line.
- For agents: `rq.ui.get` gives the question's text in `select.message`.

## 1.0.0

First version.
- The MORU RUN button on the status page, greyed with nothing absorbed and during a quest, with the
  absorbed items in its tip.
- The Morurun Items page: the five absorbed slots, REMOVE, and SWAP with a special item from the
  vault or the one the character wears, each after the game's Yes/No.
- Config → Mods: Destroy Item on Removal/Change? (checked by default).
