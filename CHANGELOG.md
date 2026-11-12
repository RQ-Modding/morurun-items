# Changelog

Each section is a version of the mod, the `version` in `mod.json`. The release workflow copies the
section of a tagged version into the release notes.

## 1.4.0

- The page is laid out as the game's storage screen: the slots on the storage's panel at the
  left, and the vault's special items on the vault's panel at the right, always shown, with the
  vault's rank buttons, Locked / Unlocked, the count and SORT (`rq.uikit.item_picker`'s `type`,
  `only` and `first`, loader 2.44.0). Under the slots a bar holds SWAP / ABSORB, REMOVE and the
  notes, as Config's bottom bar does.
- An item is marked with a click and goes in with SWAP / ABSORB, with a double click, or dragged
  onto a slot; a slot dragged onto the vault's list is REMOVE.
- A locked item is listed with its lock, as in the vault, and SWAP on it says to unlock it in the
  vault first (it was greyed).
- For agents: the right list's rows are `row-morurun-pick-list-N` (were `row-morurun-pick-N`,
  shown after SWAP); `page()` has `mark` (the marked item) in place of `picking` and `rows`.
- Needs loader 2.44.0.

## 1.3.1

- The Config page is built with the loader's `rq.config.settings` (loader 2.35.0): the same two
  checkboxes and texts, kept under the same keys, so your settings stay, and a **Reset** button.

## 1.3.0

- **ABSORB**, with the new setting **Allow Absorbing into an Empty Slot?** (unchecked by default, as
  the game does): an empty slot that a Morurun opened takes a special item from the vault, or the
  one worn, with the game's Yes/No first. Each Morurun opens one slot, up to five, so a character
  with three Moruruns fills only up to three; the others show "Not open yet". Athena never has one.
- The button opens for a character with an open slot and nothing absorbed, while the setting is on.
- SWAP no longer offers a worn special item the game will not take off (Athena's): it is greyed.
- When the game has no room for an item going back to the vault (3000 items in all), the notice
  says so.
- For agents: `fill_on`, `set_fill`, `open_slots` and `tip` in `rq.mod.get("morurun-items")`.

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
