# Morurun Items

Change the special items the Morurun absorbed into a character, from the character's status page,
without playing Alice's Mansion and without resetting the character.

## Showcase

### Morurun icon at Status

<img width="737" height="441" alt="image" src="https://github.com/user-attachments/assets/08a30f00-a2de-4b13-825a-dd34f476f1ab" />

### Morurun Editor

<img width="1266" height="955" alt="image" src="https://github.com/user-attachments/assets/ad0353a6-90ce-4842-8a60-29f628f16c44" />

### Mod Options

<img width="1267" height="907" alt="image" src="https://github.com/user-attachments/assets/6d0355e9-9939-4474-9ae5-c1b32772c396" />


## What it changes

- A **MORU RUN** button on the status page, left of the X. It is greyed when the character has
  absorbed nothing, and during a quest. Hold the mouse over it to see what the character absorbed.
- The button opens **Morurun Items**, laid out as the game's storage screen: the character's five
  absorbed slots on the left, with each item's stats, and the special items in the vault on the
  right, with the vault's rank buttons, Locked / Unlocked, the count and SORT. A bar under the
  slots holds the buttons.
  - **SWAP**: click an item on the right to mark it, pick a slot on the left, and press SWAP. A
    double click on an item, or dragging it onto a slot, does the same. The item you put in is used
    up, as the Morurun uses it up. The special item the character wears is listed first; a worn
    item the game will not take off (Athena's) is greyed. A locked item stays locked: unlock it in
    the vault first. Items the Morurun never absorbs (Forbidden Talent and its kind) are not shown.
  - **REMOVE**, or dragging a slot onto the vault's list, takes the item out of the character.
  - **ABSORB**, with the setting below on: an empty slot that a Morurun opened takes a special item
    the same way.
- All of them ask first, with the game's Yes/No.
- The character's stats change at once, as when the Morurun absorbs an item.

By default the item taken out is **destroyed**, as Alice's Mansion does.

**Open slots.** Each Morurun opens one slot, up to five: the character absorbs the special item
it wears then, or nothing when it wears none. A character with three Moruruns has three slots open,
and fills an empty one of them only. Athena never levels, so she never has a Morurun and has no slot
open.

## Keys and settings

- Config → Mods → **Morurun Items**: **Destroy Item on Removal/Change?** Checked (the default): an
  item taken out is destroyed. Unchecked: it goes back to the vault.
- **Allow Absorbing into an Empty Slot?** Unchecked (the default), as the game does: only a
  Morurun puts an item in a slot. Checked: an open slot left empty takes a special item with
  ABSORB, the button opens for a character with an open slot and nothing absorbed, and a slot that
  no Morurun opened shows "Not open yet".
- **Reset** on that page puts both back to their defaults.
- Both settings hold for every save profile.
- The button and the page work with the mouse. The arrow keys reach the button (Up from the Special
  slot, then Enter), and the page takes the arrow keys and Enter.
- Right click, Esc or the X closes the page.

## Saves

The absorbed items are the game's own data: what you change stays in the save after the mod is
removed. The settings are in `rqmod-global.json`, which the game ignores.

## Works with

Tested with every RQ Modding mod installed. It touches no other mod's data.

## Install

Needs [RQ MOD](https://github.com/RQ-Modding/RQ-Mod) with loader **2.44.0** or newer. Extract the
release zip into the game's `mods` folder, so that you have `mods/morurun-items/mod.json`.

## License

MIT, see [LICENSE](LICENSE).
