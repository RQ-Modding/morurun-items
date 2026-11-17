# Testing Morurun Items

For people and agents who test the mod in the game. Read it before you use anything the mod adds.
Assume nothing about the mod when it is not installed: check `logs\rqmod.log` for
`Morurun Items loaded`.

## What it adds

The button is one of the status page's own (`rq.gamebutton`'s `"status"` group, section
`agent`); the page and its widgets are kit widgets (section `kit`).

| id | where | what |
| --- | --- | --- |
| `morurun-items.open` | Status page, left of the X (472, 61), 32 by 29 | Opens the page. `enabled` false during a quest, and when the character has nothing absorbed and no open slot to fill (or the fill setting is off); its tip (the game's comment window) says why |
| `page-morurun-items` | The whole screen, 0, 0, 1024 by 768 | The page, laid out as the game's storage screen; Esc, a right click or its X (top right) closes it |
| `row-morurun-slots-1` .. `-5` | The left list (x 101), 5 shown | The absorbed slots. An empty slot is `enabled` false, except an open one while the fill setting is on; "Not open yet" is a slot no Morurun opened |
| `button-morurun-swap`, `button-morurun-remove` | The bar under the slots (108, 682 and 216, 682) | SWAP is `enabled` with a filled slot chosen and an item marked on the right; on an open empty slot it reads ABSORB (its `label`). REMOVE is `enabled` with a filled slot chosen. A greyed button's tip says what is missing |
| `row-morurun-pick-list-N` | The right list (x 538), from its second row (the rank buttons sit over the first) | The worn special item first, then the vault's special items (`rq.uikit.item_picker`). A click marks one; a double click, or dragging it onto a slot, puts it in that slot. A worn one that cannot be removed is `enabled` false; a locked one shows LOCKED, and putting it in gives the game's notice "... is locked" |
| `tab-morurun-pick-sort-default-so` | Bottom right | The vault's SORT (the kit cuts the key at 28 characters); the filter column over it keeps Special picked, with the vault's rank buttons and Locked / Unlocked |

With more than two mods' buttons on the status page (loader 2.59.0 and later), the buttons are
one **MODS** button (`status-mods`) over both cells, and this button is a row of the list it opens:
press `status-mods`, then `button-morurun-items-open` (`rq.gamebutton.groups()` says which).

- **The game's question.** SWAP / ABSORB, REMOVE, a double click on a right row, and a drop (an
  item onto a slot, or a slot onto the right list, which is REMOVE) ask with the game's Yes/No: the
  screen becomes `select`, with `yes` and `no`, and `select.message` holds the question. The page
  stays under it. A locked item gives the game's notice instead (`yes` is its OK).
- **Config.** The Mods tab has the page **Morurun Items** with two checkboxes, **Destroy Item on
  Removal/Change?** (`destroy`, checked by default) and **Allow Absorbing into an Empty Slot?**
  (`fill`, unchecked by default), and **Reset** (`reset`), which puts both back. The page is
  `rq.config.settings`'s; the values stay in `rq.store.global` under `destroy` and `fill`.
- **Open slots.** A character has `min(5, rebirths)` slots open (`rq.chara.get(iic).rebirths`, the
  Moruruns it had). While the absorbed items are fewer, the first empty slots up to that count can
  be filled. Athena 2.0 never levels, so she has none.
- **Covered controls.** The page covers the whole status page
  while it is open, so `press` refuses the game's controls then (`"covered": true`).
- **Keys.** The status page's keys reach the button: Up from the Special slot, then Enter. The
  page takes the arrow keys and Enter while it is open.

## How to check it

1. Open a character's status page (Party → a unit's status). Pick one with absorbed items; Rance has
   some in most saves (`rq.chara.absorbed(iic)` reads the five slots, 0 is empty).
2. `morurun-items.open` is enabled, and its tip lists the items. On a character with five empty slots it
   is `enabled` false.
3. Press it, press a filled `row-morurun-slots-N`, press `button-morurun-remove`, answer `yes`. The
   slot reads 0, and the page's `status.stats` match the game's (`Ｃ攻撃力` and the others): the card
   is drawn again.
4. Press a filled slot, then a `row-morurun-pick-list-N` (it is marked), then `button-morurun-swap`,
   answer `yes`. The slot holds the marked item's number and the instance is gone
   (`rq.item.get(ii)` is nil). Pressing the same right row twice in a row (a double click) does the
   same without SWAP; `drag` from a right row to a slot row too.
5. With the fill setting on and a character with an open slot (more Moruruns than items), press
   the open slot's row, mark a right row, press `button-morurun-swap` (it reads ABSORB), and answer
   `yes`. The slot holds the item's number.
6. `drag` from a filled slot row to a right row: the question to remove.

## Forcing it for a test

- `rq.mod.get("morurun-items")` returns `destroy_on()`, `set_destroy(on)`, `fill_on()` and
  `set_fill(on)` (the Config settings), `open_slots(iic)` (the set of slots that can be filled, and
  how many), `tip(iic)` (the button's tip), `page()` (the open page's state: `iic`, `slot`, `mark`,
  the item marked on the right) and `button` (the `rq.gamebutton` handle;
  `button.set({ shown = false })` frees its cell for another test). Put the settings back after
  the test.
- The right list is `rq.uikit.state("picker:morurun-pick")`: `list` (instances, and a row table
  for the worn item first) and `ii` (the marked one). `rq.uikit.state("itemlist:morurun-pick-list").top`
  scrolls it (rows above the first shown); `"itemlist:morurun-slots"` scrolls the slots.
- `rq.chara.set(iic, { rebirths = n })` gives a character n Moruruns for a test; put it back after.
- `rq.item.give(274)` puts Solid Gold Bear (attack +100) in the vault; `rq.item.give(276, { to = iic })`
  makes a character wear one.
- `scrollStatus(ステータス_キャラ一覧_インデクス(iic))` through `rq.ain.call` shows a character on an
  open status page; `rq.statuspage.chara()` says which one shows.

## Test Lab

`test-lab/scenarios/morurun-items.lua`: the button on both kinds of character, its place and tip,
the page's rows, REMOVE with No and Yes, SWAP with a vault item and with the worn one, the picker's
rules (no Forbidden Talent, locked greyed), the card after each change, and the setting unchecked.
Since 1.3.0 also: ABSORB into an open slot (No, then Yes), the slots no Morurun opened, a
character with no Morurun, a worn item that cannot be removed, the button greyed during a quest
with its tip, and a full item table with the destroy setting unchecked (the notice "There is no
room for ...", and nothing changes).
Since 1.4.0: an item marked on the right then SWAP, the mark gone once the item is used up, a
locked item refused with the notice, the worn item by a double click, a slot dragged onto the
right list as REMOVE, an item dragged onto an open slot (No), then marked and ABSORB, the SORT
there and the Special category kept.
Shots: `morurun-button.png`, `morurun-page.png`, `morurun-ask.png`, `morurun-pick.png`,
`morurun-absorb.png`, `morurun-quest.png`, `morurun-full.png`.
