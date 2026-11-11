-- Morurun Items: a button on a character's status page that lists the special items the Morurun
-- absorbed into the character, and removes one or swaps it with a special item from the vault,
-- without quest 13 (Alice's Mansion). The game's rule by default: the item taken out is destroyed.
-- With a setting on, an empty slot a Morurun opened takes a special item too (1.3.0).
-- API reference: https://rq-modding.github.io/rq-modding-docs/reference/
--
-- The game keeps the absorbed items in five slots, Ｃ[iic].ＦＡ[17] to ＦＡ[21], as item numbers;
-- Ｃ体内特殊アイテムの効果計算 adds their stats on every recalculation (notes/plans/plan-morurun-items.md
-- in the workspace). The button is one of the status page's own (rq.gamebutton "status"), and the
-- page is read and drawn again with rq.statuspage (loader 2.20.0). The slots are read and written
-- with rq.chara.absorbed and set_absorbed (loader 2.23.0).
--
-- Each Morurun (Ｃレベルドレイン) adds one to the character's count (rebirths) and absorbs the worn
-- special item into the first empty slot, so a character has opened one slot per Morurun, five at
-- most. Athena 2.0 never levels, so she never has one (notes/plans/plan-morurun-camera.md 2.4).

local MOD = "Morurun Items"
local ui = rq.uikit

local SPECIAL = 21
-- Special items the game never absorbs (Ｃ体内特殊アイテムの取得処理).
local NEVER = { [304] = true, [305] = true, [306] = true, [307] = true, [309] = true, [310] = true }
local VAULT = 7
local ICON = 11158 -- The "MORU RUN" mark of the Rance Castle tab, 32 by 29.

-- ---- Settings ----

-- Kept in rq.store.global under "destroy" and "fill", as before 1.3.1, so players keep theirs.
local settings = rq.config.settings({
  id = "morurun-items",
  title = MOD,
  rows = {
    { kind = "checkbox", key = "destroy", label = "Destroy Item on Removal/Change?", default = true,
      note = { "Checked, as the game does: an item taken out of a character is destroyed.",
        "Unchecked: it goes back to the vault." } },
    { kind = "space", h = 12 },
    -- Off by default, as in the game: only a Morurun puts an item in a slot.
    { kind = "checkbox", key = "fill", label = "Allow Absorbing into an Empty Slot?", default = false,
      note = { "Each Morurun opens one slot, up to five. Checked: an open slot left empty",
        "takes a special item from the vault. Unchecked, as the game does: only a Morurun." } },
  },
})

local function destroy_on()
  return settings.get("destroy")
end

local function fill_on()
  return settings.get("fill")
end

-- ---- The game's data ----

local function slots(iic)
  return rq.chara.absorbed(iic)
end

local function any(list)
  for _, no in ipairs(list) do if no ~= 0 then return true end end
  return false
end

-- Row data for an item number, which has no instance once absorbed (rq.item.info, 2.20.0).
local function row_of(no)
  local d = rq.item.info(no)
  return { name = d and d.name or ("Item " .. no), info = d and d.info or "", icon = d and d.icon,
    rank = d and d.rank or 0, kind = SPECIAL, level = "" }
end

local function in_quest()
  return rq.quests.current() ~= 0
end

-- The Moruruns the character has had (Ｃ転生回数).
local function moruruns(iic)
  return (rq.chara.get(iic) or {}).rebirths or 0
end

-- The empty slots a Morurun opened and no item fills: one slot per Morurun, five at most, less the
-- items absorbed. They are the first empty slots in order, as the game fills the first empty one.
-- Returns a set of slot numbers and how many.
local function open_slots(iic)
  local list = slots(iic)
  local filled = 0
  for _, no in ipairs(list) do if no ~= 0 then filled = filled + 1 end end
  local free = math.max(0, math.min(5, moruruns(iic)) - filled)
  local set, n = {}, 0
  for i, no in ipairs(list) do
    if no == 0 and n < free then
      set[i] = true
      n = n + 1
    end
  end
  return set, n
end

local function can_fill(iic)
  if not fill_on() then return false end
  local _, n = open_slots(iic)
  return n > 0
end

-- Special items the character could take in: in the vault (kind 21, not one the game never
-- absorbs), and the one the character wears, as quest 13 swaps with it. A worn one the game will
-- not take off (Athena's 302) is greyed.
local function candidates(iic)
  local out = {}
  local worn = (rq.item.equipped(iic) or {}).special
  if worn and not NEVER[rq.item.number(worn)] then
    local d = ui.item_data(worn)
    if d then
      d.level = "Worn now"
      local info = rq.item.get(worn)
      if info and info.locked ~= 0 then
        d.level = "Worn; cannot be removed"
        d.disabled = true
      end
      out[#out + 1] = d
    end
  end
  for _, it in ipairs(rq.items()) do
    local ii = it.id
    if it.typeId == SPECIAL and it.place == VAULT and not NEVER[it.no] then
      local d = ui.item_data(ii)
      if d then
        if d.locked then d.disabled = true end
        out[#out + 1] = d
      end
    end
  end
  return out
end

-- ---- The questions ----

-- The game's Yes / No and OK (rq.ui.confirm and rq.ui.notice, loader 2.19.0).
local function ask(text)
  return rq.ui.confirm(text) == true
end

local function notice(text)
  rq.ui.notice(text)
end

-- ---- Doing it ----

-- slot: 1 to 5. ii: the instance going in, or nil to empty the slot. An empty slot takes an item
-- only when it is open (open_slots) and the setting allows it. Asks first; true when done.
local function change(iic, slot, ii)
  local old = slots(iic)[slot]
  if old == 0 and not (ii and fill_on() and open_slots(iic)[slot]) then return false end
  local x = old ~= 0 and row_of(old).name or nil
  local destroy = destroy_on()
  local text
  if ii then
    local y = ui.item_data(ii)
    y = y and y.name or "?"
    if old == 0 then
      local name = (rq.chara.get(iic) or {}).name or "?"
      text = "Absorb (" .. y .. ") into " .. name .. "?\n" .. y .. " is used up, as by the Morurun."
    else
      text = "Switch absorbed item (" .. x .. ") with (" .. y .. ")?\n"
        .. (destroy and (x .. " will be destroyed.") or (x .. " goes back to the vault."))
    end
  else
    text = destroy and ("Destroy absorbed item (" .. x .. ")?")
      or ("Remove absorbed item (" .. x .. ")?\nIt goes back to the vault.")
  end
  if not ask(text) then return false end
  if old ~= 0 and not destroy then
    local back, err = rq.item.give(old)
    if not back then
      -- The game holds 3000 items in all (Ｉ空き番号取得): the vault, what is worn, the shop, quest storage.
      notice("There is no room for " .. x .. ":\nthe game holds at most 3000 items.")
      rq.log(MOD .. ": give " .. old .. " failed: " .. tostring(err))
      return false
    end
  end
  local new = 0
  if ii then
    new = rq.item.number(ii)
    rq.item.remove(ii) -- taken off first when worn, as quest 13 does
  end
  rq.chara.set_absorbed(iic, slot, new) -- recalculates, and heals outside a quest
  rq.statuspage.refresh()
  rq.sound.play(new > 0 and 5003 or 5004) -- the game's equip and unequip sounds
  rq.log(string.format("%s: chara %d slot %d: %d -> %d%s", MOD, iic, slot, old, new,
    destroy and "" or " (old one to the vault)"))
  return true
end

-- ---- The button and the page ----

local page = nil      -- { iic, slot, picking, rows, pending }
local busy = false    -- the game's question is up (its loop runs our updates inside the call)

local function names_of(list)
  local out = {}
  for _, no in ipairs(list) do
    if no ~= 0 then out[#out + 1] = row_of(no).name end
  end
  return table.concat(out, "\n")
end

local function plural(n, one, many)
  return n .. " " .. (n == 1 and one or many)
end

local function tip_of(iic)
  if not iic then return "" end
  local list = slots(iic)
  local text
  if any(list) then
    text = names_of(list)
  elseif can_fill(iic) then
    local _, n = open_slots(iic)
    text = "Nothing absorbed yet.\n" .. plural(n, "slot is", "slots are") .. " open for a special item."
  else
    return "Nothing absorbed by the Morurun."
  end
  if in_quest() then text = text .. "\nNot during a quest." end
  return text
end

-- The button: the game's own, in the status page's title row (rq.gamebutton "status").
local button = rq.gamebutton.add({
  group = "status",
  id = "open",
  label = MOD,
  icon = ICON,
  enabled = function(iic)
    return iic ~= nil and not in_quest() and (any(slots(iic)) or can_fill(iic))
  end,
  tip = tip_of,
  on_click = function()
    local iic = rq.statuspage.chara()
    if iic then page = { iic = iic, slot = nil, picking = false } end
  end,
})

rq.statuspage.on_close(function() page = nil end)
rq.statuspage.on_chara(function() page = nil end)

-- The five slots as rows. An empty slot can be chosen only when it is open and the setting is on;
-- `open` marks those rows.
local function slot_rows(iic)
  local out = {}
  local open = fill_on() and open_slots(iic) or {}
  local count = moruruns(iic)
  for i, no in ipairs(slots(iic)) do
    if no ~= 0 then
      local r = row_of(no)
      out[i] = { name = r.name, info = r.info, icon = r.icon, rank = r.rank, kind = SPECIAL, level = "Slot " .. i }
    elseif open[i] then
      out[i] = { name = "Empty slot", info = "A Morurun opened this slot: it can absorb a special item.",
        level = "Slot " .. i, open = true }
    elseif fill_on() then
      out[i] = { name = "Not open yet", level = "Slot " .. i, disabled = true,
        info = "Each Morurun opens one slot (" .. plural(count, "Morurun", "Moruruns") .. " so far)." }
    else
      out[i] = { name = "Empty slot", info = "", level = "Slot " .. i, disabled = true }
    end
  end
  return out
end

local function draw_page()
  local p = page
  local name = (rq.chara.get(p.iic) or {}).name or ""
  local open = ui.page({ id = "morurun-items", title = MOD .. ": " .. name, x = 0, y = 56, w = 1024, h = 680 },
    function(x, y)
      local rows = slot_rows(p.iic)
      local slot, changed = ui.item_list(rows, p.slot, { x = x, y = y, shown = 4, id = "morurun-slots", style = "equip" })
      p.slot = slot
      if changed then p.picking = false end
      local row = slot and rows[slot]
      local empty = row and row.open == true -- an open slot to fill
      local filled = row and not row.disabled and not empty
      local by = y + 4 * 128 + 8
      if ui.button(empty and "ABSORB" or "SWAP", { style = "short", x = x, y = by, id = "morurun-swap",
          disabled = not (filled or empty),
          tip = empty and "Absorb a special item from the vault into this open slot."
            or "Put a special item from the vault in this slot." }) then
        p.picking = true
        p.rows = candidates(p.iic)
      end
      if ui.button("REMOVE", { style = "short", x = x + 108, y = by, id = "morurun-remove", disabled = not filled,
          tip = "Take this item out of the character." }) and not busy then
        p.pending = { slot = slot }
      end
      ui.label(destroy_on() and "Items taken out are destroyed (Config, Mods tab)."
        or "Items taken out go back to the vault (Config, Mods tab).",
        { x = x, y = by + 36, size = 15, dim = true })
      if p.picking and (filled or empty) then
        ui.label("Special items in the vault", { x = x + 500, y = y - 2, size = 17 })
        if #p.rows == 0 then
          ui.label("None that the Morurun can absorb.", { x = x + 500, y = y + 30, size = 15, dim = true })
        else
          local pick, _, _, _, chosen = ui.item_list(p.rows, nil, { x = x + 500, y = y + 24, shown = 4,
            id = "morurun-pick", style = "equip" })
          if chosen and pick and not busy then
            local row = p.rows[pick]
            if row and not row.disabled then p.pending = { slot = slot, ii = row.ii } end
          end
        end
      end
    end)
  if not open then page = nil end
end

rq.on_frame(function()
  if page and not rq.statuspage.chara() then page = nil end
  if page then
    draw_page()
    -- Out of the page's layout: the game's question runs its own loop, which draws the page again.
    local p = page
    if p and p.pending and not busy then
      local job = p.pending
      p.pending = nil
      busy = true
      local ok, err = pcall(change, p.iic, job.slot, job.ii)
      busy = false
      if not ok then rq.log(MOD .. ": " .. tostring(err)) end
      p.picking = false
    end
  end
end)

rq.log(MOD .. " loaded")

-- For tests and other mods (rq.mod.get("morurun-items")): the settings, the open slots, the
-- button's tip and the page's state.
return {
  destroy_on = destroy_on,
  set_destroy = function(on) settings.set("destroy", on ~= false) end,
  fill_on = fill_on,
  set_fill = function(on) settings.set("fill", on == true) end,
  open_slots = open_slots,
  tip = tip_of,
  page = function() return page end,
  button = button,
}
