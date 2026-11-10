# Testing Morurun Items

For people and agents who test the mod in the game. Read it before you use anything the mod adds.
Assume nothing about the mod when it is not installed: check `logs\rqmod.log` for
`Morurun Items loaded`.

## What it adds

The button is one of the status page's own (`rq.gamebutton`'s `"status"` group, section
`agent`); the page and its widgets are kit widgets (section `kit`).

| id | where | what |
| --- | --- | --- |
| `morurun-items.open` | Status page, left of the X (472, 61), 32 by 29 | Opens the page. `enabled` false when the character has nothing absorbed, or during a quest; its tip (the game's comment window) says why |
| `page-morurun-items` | Over the town, 0, 56, 1024 by 680 | The page; Esc, a right click or its X closes it |
| `row-morurun-slots-1` .. `-5` | The page's left list, 4 shown | The absorbed slots; an empty slot is `enabled` false |
| `button-morurun-swap`, `button-morurun-remove` | Under the slots | `enabled` only with a filled slot chosen |
| `row-morurun-pick-N` | The page's right list, after SWAP | The worn special item first, then the vault's; a locked one is `enabled` false |

- **The game's question.** REMOVE, and a click on a picker row, ask with the game's Yes/No: the
  screen becomes `select`, with `yes` and `no`, and `select.message` holds the question. The page
  stays under it.
- **Config.** The Mods tab has the page **Morurun Items** with one checkbox, **Destroy Item on
  Removal/Change?**.
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

## Forcing it for a test

- `rq.mod.get("morurun-items")` returns `destroy_on()`, `set_destroy(on)` (the Config setting),
  `page()` (the open page's state: `iic`, `slot`, `picking`, `rows` of the picker) and `button`
  (the `rq.gamebutton` handle; `button.set({ shown = false })` frees its cell for another test). Put the setting
  back after the test.
- `rq.item.give(274)` puts Solid Gold Bear (attack +100) in the vault; `rq.item.give(276, { to = iic })`
  makes a character wear one.
- `scrollStatus(ステータス_キャラ一覧_インデクス(iic))` through `rq.ain.call` shows a character on an
  open status page; `rq.statuspage.chara()` says which one shows.

## Test Lab

`test-lab/scenarios/morurun-items.lua`: the button on both kinds of character, its place and tip,
the page's rows, REMOVE with No and Yes, SWAP with a vault item and with the worn one, the picker's
rules (no Forbidden Talent, locked greyed), the card after each change, and the setting unchecked.
Shots: `morurun-button.png`, `morurun-page.png`, `morurun-ask.png`, `morurun-pick.png`.

Not checked by the Lab: the button during a quest (greyed while `rq.quests.current()` is not 0), and a full vault when
the setting is unchecked (the game's notice "The vault cannot take ...").
