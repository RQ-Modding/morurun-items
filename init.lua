-- Morurun Items: a button on a character's status page that lists the special items the Morurun
-- absorbed into the character, and removes one or swaps it with a special item from the vault,
-- without quest 13 (Alice's Mansion). The game's rule by default: the item taken out is destroyed.
-- API reference: https://rq-modding.github.io/rq-modding-docs/reference/
--
-- It works on the game's own data through rq.ain (notes/plans/plan-morurun-items.md in the
-- workspace). The game keeps the absorbed items in five slots, Ｃ[iic].ＦＡ[17] to ＦＡ[21], as item
-- numbers; Ｃ体内特殊アイテムの効果計算 adds their stats on every recalculation.

local MOD = "Morurun Items"
local ui = rq.uikit
local call = rq.ain.call
local hook = rq.ain.hook

local SLOTS = { 17, 18, 19, 20, 21 }
local SPECIAL = 21
-- Special items the game never absorbs (Ｃ体内特殊アイテムの取得処理).
local NEVER = { [304] = true, [305] = true, [306] = true, [307] = true, [309] = true, [310] = true }
local VAULT = 7
local ICON = 11158 -- The "MORU RUN" mark of the Rance Castle tab, 32 by 29.

-- ---- Settings ----

local function destroy_on()
  return rq.store.global.get("destroy", true) ~= false
end

if rq.config then
  rq.config.page({
    id = "morurun-items",
    title = MOD,
    draw = function(kit, box)
      local v, changed = kit.checkbox(destroy_on(), "Destroy Item on Removal/Change?", { id = "destroy" })
      if changed then rq.store.global.set("destroy", v) end
      kit.label("Checked, as the game does: an item taken out of a character is destroyed.", { dim = true })
      kit.label("Unchecked: it goes back to the vault.", { dim = true })
    end,
  })
end

-- ---- The game's data ----

local function slots(iic)
  local out = {}
  for i, n in ipairs(SLOTS) do out[i] = call("ＣＦＡ", iic, n, -1) end
  return out
end

local function any(list)
  for _, no in ipairs(list) do if no ~= 0 then return true end end
  return false
end

-- Row data for an item number, which has no instance once absorbed: the game's own way
-- (Ｉ固有名前 makes a temporary instance and deletes it). Kept per number.
local rows_by_no = {}
local function row_of(no)
  local r = rows_by_no[no]
  if r then return r end
  local ii = call("Ｉ生成", no, 0)
  local d = ii and ii > 0 and ui.item_data(ii) or nil
  if ii and ii > 0 then call("Ｉ削除", ii) end
  r = { name = d and d.name or ("Item " .. no), info = d and d.info or "", icon = d and d.icon,
        rank = d and d.rank or 0, kind = SPECIAL, level = "" }
  rows_by_no[no] = r
  return r
end

-- The character on the status page (T_StatusCard::getCharaNo).
local function status_chara()
  local ok, iic = pcall(rq.ain.global, "g_sStatus", "m_sCard", "m_sEquipSkill", "m_sList", "m_nCharaNo")
  if ok and math.type(iic) == "integer" and iic > 0 then return iic end
end

local function in_quest()
  return call("クエスト_攻略中") == true
end

-- Special items the character could take in: in the vault (kind 21, not one the game never
-- absorbs), and the one the character wears, as quest 13 swaps with it.
local function candidates(iic)
  local out = {}
  local worn = (rq.item.equipped(iic) or {}).special
  if worn and not NEVER[call("Ｉ固有番号", worn, -1)] then
    local d = ui.item_data(worn)
    if d then
      d.level = "Worn now"
      out[#out + 1] = d
    end
  end
  for _, it in ipairs(rq.items()) do
    local ii = it.id
    if it.typeId == SPECIAL and call("アイテム_存在", ii) == VAULT and not NEVER[call("Ｉ固有番号", ii, -1)] then
      local d = ui.item_data(ii)
      if d then
        if d.locked then d.disabled = true end
        out[#out + 1] = d
      end
    end
  end
  return out
end

-- ---- The status page's card ----

-- The card is drawn once (T_StatusCard::set). T_Status::scroll sets it again when the character
-- changes: scroll to the same character with the old one read as another, once, and without the
-- window sound that scroll plays.
local function refresh_card(iic)
  local idx = call("ステータス_キャラ一覧_インデクス", iic)
  if math.type(idx) ~= "integer" or idx < 0 then return false end
  local first, quiet = true, true
  local r1 = hook("T_StatusCard@getCharaNo", { before = function(h)
    if first then first = false; h.skip = true; h.result = 999999 end
  end })
  local r2 = hook("効果音_窓開き", { before = function(h)
    if quiet then quiet = false; h.skip = true end
  end })
  local ok, err = pcall(call, "scrollStatus", idx)
  r1(); r2()
  if not ok then rq.log(MOD .. ": refresh failed: " .. tostring(err)) end
  return ok
end

-- ---- The questions ----

local function ask(text)
  return call("選択_確認", text, 1, "Yes", "No", -1, -1, false) == true
end

local function notice(text)
  call("選択_通知", text, "OK", false)
end

-- ---- Doing it ----

-- slot: 1 to 5. ii: the instance going in, or nil to empty the slot. Asks first; true when done.
local function change(iic, slot, ii)
  local old = slots(iic)[slot]
  if old == 0 then return false end
  local x = row_of(old).name
  local destroy = destroy_on()
  local text
  if ii then
    local y = ui.item_data(ii)
    y = y and y.name or "?"
    text = "Switch absorbed item (" .. x .. ") with (" .. y .. ")?@"
      .. (destroy and (x .. " will be destroyed.") or (x .. " goes back to the vault."))
  else
    text = destroy and ("Destroy absorbed item (" .. x .. ")?")
      or ("Remove absorbed item (" .. x .. ")?@It goes back to the vault.")
  end
  if not ask(text) then return false end
  if not destroy then
    local back, err = rq.item.give(old)
    if not back then
      notice("The vault cannot take " .. x .. ".")
      rq.log(MOD .. ": give " .. old .. " failed: " .. tostring(err))
      return false
    end
  end
  local new = 0
  if ii then
    new = call("Ｉ固有番号", ii, -1)
    rq.item.remove(ii) -- taken off first when worn, as quest 13 does
  end
  call("ＣＦＡ", iic, SLOTS[slot], new)
  rq.chara.recalc(iic, not in_quest())
  refresh_card(iic)
  call("効果音_アイテム装備", new)
  rq.log(string.format("%s: chara %d slot %d: %d -> %d%s", MOD, iic, slot, old, new,
    destroy and "" or " (old one to the vault)"))
  return true
end

-- ---- The button and the page ----

local theme = ui.copy_theme(ui.themes.hub)
theme.styles = theme.styles or {}
theme.styles.button = theme.styles.button or {}
theme.styles.button.morurun = { normal = { cg = ICON }, hover = { cg = ICON }, w = 32, h = 29, cover = true }

local depth = 0       -- inside ステータス_実行
local screen_at, on_status, close_at = -1, false, nil
local page = nil      -- { iic, slot, picking, rows, pending }
local busy = false    -- the game's question is up (its loop runs our updates inside the call)

hook("ステータス_実行", {
  before = function() depth = depth + 1 end,
  after = function() depth = math.max(0, depth - 1); if depth == 0 then page = nil end end,
})

-- The status page's screen and its X, read a few times a second.
local function status_shown()
  local now = rq.time_ms()
  if now - screen_at >= 150 then
    screen_at = now
    local s = rq.ui.get()
    on_status = s ~= nil and s.screen == "status"
    close_at = nil
    if on_status then
      for _, c in ipairs(s.controls or {}) do
        if c.id == "close" then close_at = c; break end
      end
    end
  end
  return on_status
end

local function names_of(list)
  local out = {}
  for _, no in ipairs(list) do
    if no ~= 0 then out[#out + 1] = row_of(no).name end
  end
  return table.concat(out, "\n")
end

local function draw_button(iic)
  local list = slots(iic)
  local quest = in_quest()
  local has = any(list)
  local tip
  if not has then
    tip = { header = MOD, text = "Nothing absorbed by the Morurun." }
  elseif quest then
    tip = { header = MOD, text = names_of(list), sub = "Not during a quest." }
  else
    tip = { header = MOD, text = names_of(list) }
  end
  local x = close_at and (close_at.x - 38) or 472
  local y = close_at and (close_at.y - 4) or 61
  local was = ui.theme
  ui.use(theme)
  local clicked = ui.button("", { style = "morurun", x = x, y = y, id = "morurun", disabled = not has or quest, tip = tip })
  ui.use(was)
  if clicked then page = { iic = iic, slot = nil, picking = false } end
end

local function slot_rows(iic)
  local out = {}
  for i, no in ipairs(slots(iic)) do
    if no ~= 0 then
      local r = row_of(no)
      out[i] = { name = r.name, info = r.info, icon = r.icon, rank = r.rank, kind = SPECIAL, level = "Slot " .. i }
    else
      out[i] = { name = "Empty slot", info = "", level = "Slot " .. i, disabled = true }
    end
  end
  return out
end

local function draw_page()
  local p = page
  local name = call("Ｃ名前", p.iic, "")
  local open = ui.page({ id = "morurun-items", title = MOD .. ": " .. name, x = 0, y = 56, w = 1024, h = 680 },
    function(x, y)
      local rows = slot_rows(p.iic)
      local slot, changed = ui.item_list(rows, p.slot, { x = x, y = y, shown = 4, id = "morurun-slots", style = "equip" })
      p.slot = slot
      if changed then p.picking = false end
      local filled = slot and rows[slot] and not rows[slot].disabled
      local by = y + 4 * 128 + 8
      if ui.button("SWAP", { style = "short", x = x, y = by, id = "morurun-swap", disabled = not filled,
          tip = "Put a special item from the vault in this slot." }) then
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
      if p.picking and filled then
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
  if depth == 0 then return end
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
    return
  end
  if not status_shown() then return end
  local iic = status_chara()
  if iic then draw_button(iic) end
end)

rq.log(MOD .. " loaded")

-- For tests and other mods (rq.mod.get("morurun-items")): the setting and the page's state.
return {
  destroy_on = destroy_on,
  set_destroy = function(on) rq.store.global.set("destroy", on ~= false) end,
  page = function() return page end,
}
