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
| `page-morurun-items` | Over the town, 0, 56, 1024 by 680 | The page; Esc, a right click or its X closes it |
| `row-morurun-slots-1` .. `-5` | The page's left list, 4 shown | The absorbed slots. An empty slot is `enabled` false, except an open one while the fill setting is on; "Not open yet" is a slot no Morurun opened |
| `button-morurun-swap`, `button-morurun-remove` | Under the slots | `enabled` only with a filled slot chosen. On an open empty slot the first reads ABSORB (its `label`) and is `enabled`, and REMOVE is not |
| `row-morurun-pick-N` | The page's right list, after SWAP or ABSORB | The worn special item first, then the vault's; a locked one, and a worn one that cannot be removed, are `enabled` false |

- **The game's question.** REMOVE, and a click on a picker row, ask with the game's Yes/No: the
  screen becomes `select`, with `yes` and `no`, and `select.message` holds the question. The page
  stays under it.
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
4. Press a filled slot, `button-morurun-swap`, then a `row-morurun-pick-N`, answer `yes`. The slot
   holds the picked item's number and the instance is gone (`rq.item.get(ii)` is nil).
5. With the fill setting on and a character with an open slot (more Moruruns than items), press
   the open slot's row, `button-morurun-swap` (it reads ABSORB), a `row-morurun-pick-N`, and answer
   `yes`. The slot holds the item's number.

## Forcing it for a test

- `rq.mod.get("morurun-items")` returns `destroy_on()`, `set_destroy(on)`, `fill_on()` and
  `set_fill(on)` (the Config settings), `open_slots(iic)` (the set of slots that can be filled, and
  how many), `tip(iic)` (the button's tip), `page()` (the open page's state: `iic`, `slot`,
  `picking`, `rows` of the picker) and `button` (the `rq.gamebutton` handle;
  `button.set({ shown = false })` frees its cell for another test). Put the settings back after
  the test.
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
Shots: `morurun-button.png`, `morurun-page.png`, `morurun-ask.png`, `morurun-pick.png`,
`morurun-absorb.png`, `morurun-quest.png`, `morurun-full.png`.
