# Morurun Items

Change the special items the Morurun absorbed into a character, from the character's status page,
without playing Alice's Mansion and without resetting the character.

## What it changes

- A **MORU RUN** button on the status page, left of the X. It is greyed when the character has
  absorbed nothing, and during a quest. Hold the mouse over it to see what the character absorbed.
- The button opens **Morurun Items**: the character's five absorbed slots, with each item's stats.
  - **REMOVE** takes the item out of the character.
  - **SWAP** shows the special items in the vault, and the one the character wears; pick one to
    put it in the slot. The item you pick is used up, as the Morurun uses it up. Locked items are
    greyed, and items the Morurun never absorbs (Forbidden Talent and its kind) are not shown.
- Both ask first, with the game's Yes/No.
- The character's stats change at once, as when the Morurun absorbs an item.

By default the item taken out is **destroyed**, as Alice's Mansion does.

## Keys and settings

- Config → Mods → **Morurun Items**: **Destroy Item on Removal/Change?** Checked (the default): an
  item taken out is destroyed. Unchecked: it goes back to the vault. The setting holds for every
  save profile.
- The button and the page work with the mouse. The page also takes the arrow keys and Enter; the
  game's own cursor on the status page does not reach the button yet.

## Saves

The absorbed items are the game's own data: what you change stays in the save after the mod is
removed. The setting is in `rqmod-global.json`, which the game ignores.

## Works with

Tested with every mod in the workspace installed. It touches no other mod's data.

## Install

Needs [RQ MOD](https://github.com/RQ-Modding/RQ-Mod) with loader **2.13.0** or newer. Extract the
release zip into the game's `mods` folder, so that you have `mods/morurun-items/mod.json`.

## License

MIT, see [LICENSE](LICENSE).
