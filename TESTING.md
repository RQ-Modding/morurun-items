# Testing Morurun Items

For people and agents who test the mod in the game. Read it before you use anything the mod adds.
Assume nothing about the mod when it is not installed: check `logs\rqmod.log` for
`Morurun Items loaded`.

## What it adds

All are kit widgets, listed by `rqmod-ctl ui` with `"section": "kit"`.

| id | where | what |
| --- | --- | --- |
| `button-morurun` | Status page, left of the X (472, 61 when the X is at 510, 65), 32 by 29 | Opens the page. `enabled` false when the character has nothing absorbed, or during a quest |
| `page-morurun-items` | Over the town, 0, 56, 1024 by 680 | The page; Esc, a right click or its X closes it |
| `row-morurun-slots-1` .. `-5` | The page's left list, 4 shown | The absorbed slots; an empty slot is `enabled` false |
| `button-morurun-swap`, `button-morurun-remove` | Under the slots | `enabled` only with a filled slot chosen |
| `row-morurun-pick-N` | The page's right list, after SWAP | The worn special item first, then the vault's; a locked one is `enabled` false |

- **The game's question.** REMOVE, and a click on a picker row, ask with the game's Yes/No: the
  screen becomes `select`, with `yes` and `no`. The page stays under it.
- **Config.** The Mods tab has the page **Morurun Items** with one checkbox, **Destroy Item on
  Removal/Change?**.
- **Covered controls.** The button covers no game control. The page covers the whole status page
  while it is open, so `press` refuses the game's controls then (`"covered": true`).
- **Keys.** The page takes the arrow keys and Enter; the status page's own keys do not reach the
  button.

## How to check it

1. Open a character's status page (Party → a unit's status). Pick one with absorbed items; Rance has
   some in most saves (`rq.ain.call("ＣＦＡ", iic, 17..21, -1)` reads the five slots, 0 is empty).
2. `button-morurun` is enabled, and its tip lists the items. On a character with five empty slots it
   is `enabled` false.
3. Press it, press a filled `row-morurun-slots-N`, press `button-morurun-remove`, answer `yes`. The
   slot reads 0, and the page's `status.stats` match the game's (`Ｃ攻撃力` and the others): the card
   is drawn again.
4. Press a filled slot, `button-morurun-swap`, then a `row-morurun-pick-N`, answer `yes`. The slot
   holds the picked item's number and the instance is gone (`rq.item.get(ii)` is nil).

## Forcing it for a test

- `rq.mod.get("morurun-items")` returns `destroy_on()`, `set_destroy(on)` (the Config setting) and
  `page()` (the open page's state: `iic`, `slot`, `picking`, `rows` of the picker). Put the setting
  back after the test.
- `rq.item.give(274)` puts Solid Gold Bear (attack +100) in the vault; `rq.item.give(276, { to = iic })`
  makes a character wear one.
- `scrollStatus(ステータス_キャラ一覧_インデクス(iic))` through `rq.ain.call` shows a character on an
  open status page.

## Test Lab

`test-lab/scenarios/morurun-items.lua`: the button on both kinds of character, its place and tip,
the page's rows, REMOVE with No and Yes, SWAP with a vault item and with the worn one, the picker's
rules (no Forbidden Talent, locked greyed), the card after each change, and the setting unchecked.
Shots: `morurun-button.png`, `morurun-page.png`, `morurun-ask.png`, `morurun-pick.png`.

Not checked by the Lab: the button during a quest (greyed by `クエスト_攻略中`), and a full vault when
the setting is unchecked (the game's notice "The vault cannot take ...").
