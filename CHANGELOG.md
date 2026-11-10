# Changelog

Each section is a version of the mod, the `version` in `mod.json`. The release workflow copies the
section of a tagged version into the release notes.

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
