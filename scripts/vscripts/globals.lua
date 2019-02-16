--===================================================
--=  Niklas Frykholm
-- basically if user tries to create global variable
-- the system will not let them!!
-- call GLOBAL_lock(_G)
--
--===================================================
function GLOBAL_lock(t)
  local mt = getmetatable(t) or {}
  mt.__newindex = lock_new_index
  setmetatable(t, mt)
end

--===================================================
-- call GLOBAL_unlock(_G)
-- to change things back to normal.
--===================================================
function GLOBAL_unlock(t)
  local mt = getmetatable(t) or {}
  mt.__newindex = unlock_new_index
  setmetatable(t, mt)
end

function lock_new_index(t, k, v)
  if (k~="_" and string.sub(k,1,2) ~= "__") then

    --these 2 orig
    --GLOBAL_unlock(_G)
    --error("GLOBALS are locked -- " .. k .. " must be declared local or prefix with '__' for globals.", 2)

    --these 2 mine
    print("Warning: GLOBALS are locked -- " .. k .. " should be declared local or prefix with '__' for globals.")

    --[[
    if type(v) == "table" then
      PrintTable(v, "  ")
    else
      local out = tostring(v) or "null"
      print(v)
    end
    --]]

    rawset(t, k, v)

  else
    rawset(t, k, v)
  end
end

function unlock_new_index(t, k, v)
  rawset(t, k, v)
end

--define all globals here

NULL_TABLE = {}

CONST_SELL_LOSS = 0.5
CONST_INVERSE_SELL_LOSS = 1.0/CONST_SELL_LOSS

GAMEMODE_NORMAL = 1
GAMEMODE_SCRAMBLE = 2

DIFFICULTY_NORMAL = 1
DIFFICULTY_HARD = 2
DIFFICULTY_EASY = 0

INCOME_FLAT_BY_DIFFICULTY = {}
INCOME_FLAT_BY_DIFFICULTY[DIFFICULTY_EASY] = 20
INCOME_FLAT_BY_DIFFICULTY[DIFFICULTY_NORMAL] = 20
INCOME_FLAT_BY_DIFFICULTY[DIFFICULTY_HARD] = 5

INCOME_WAVE_DIFFICULTY_MODIFIER = {}
INCOME_WAVE_DIFFICULTY_MODIFIER[DIFFICULTY_EASY] = 1.5
INCOME_WAVE_DIFFICULTY_MODIFIER[DIFFICULTY_NORMAL] = 1
INCOME_WAVE_DIFFICULTY_MODIFIER[DIFFICULTY_HARD] = 0.5

INCOME_MISSING_PLAYER_DIFFICULTY = {}
INCOME_MISSING_PLAYER_DIFFICULTY[DIFFICULTY_EASY] = 8
INCOME_MISSING_PLAYER_DIFFICULTY[DIFFICULTY_NORMAL] = 5
INCOME_MISSING_PLAYER_DIFFICULTY[DIFFICULTY_HARD] = 2

INCOME_START_GOLD_DIFFICULTY = {}
INCOME_START_GOLD_DIFFICULTY[DIFFICULTY_EASY] = 30
INCOME_START_GOLD_DIFFICULTY[DIFFICULTY_NORMAL] = 30
INCOME_START_GOLD_DIFFICULTY[DIFFICULTY_HARD] = 30

START_LIVES_DIFFICULTY = {}
START_LIVES_DIFFICULTY[DIFFICULTY_EASY] = 50
START_LIVES_DIFFICULTY[DIFFICULTY_NORMAL] = 30
START_LIVES_DIFFICULTY[DIFFICULTY_HARD] = 20

MAX_HEALTH_MULT_DIFFICULTY = {}
MAX_HEALTH_MULT_DIFFICULTY[DIFFICULTY_EASY] = 0.85
MAX_HEALTH_MULT_DIFFICULTY[DIFFICULTY_NORMAL] = 1
MAX_HEALTH_MULT_DIFFICULTY[DIFFICULTY_HARD] = 1.10

GAMEMODE = GAMEMODE_NORMAL
DIFFICULTY = DIFFICULTY_NORMAL

PLUS_MODE_ENABLED = true
PLUS_MODE_LEVEL = 0

PLUS_MODE_BONUSES = {}

PLUS_MODE_VOTE_ENABLED = false
PLUS_VOTE_STATUS = {}
PLUS_VOTE_STATUS[0] = -1
PLUS_VOTE_STATUS[1] = -1
PLUS_VOTE_STATUS[2] = -1
PLUS_VOTE_STATUS[3] = -1

PLUS_MODE_BONUSES[0] =
{
  hpBonusCreepStart = 0,--how much health we add to the creeps initaly
  hpBonusCreepPT = 0, --how much we add per wave
  hpBonusBossStart = 0,
  hpBonusBossPT = 0,
  armorBonus = 0,
  bountyBonus = 0
}

PLUS_MODE_BONUSES[1] =
{
  hpBonusCreepStart = 100000,
  hpBonusCreepPT    = 16000,
  hpBonusBossStart = 100000*10,
  hpBonusBossPT = 100000,
  armorBonus = 5,
  bountyBonus = 3
}

PLUS_MODE_BONUSES[2] =
{
  hpBonusCreepStart = 300000,
  hpBonusCreepPT    = 45000,
  hpBonusBossStart = 300000*10,
  hpBonusBossPT = 300000,
  armorBonus = 10,
  bountyBonus = 6
}

USE_RUBBERBAND = true
RUBBERBAND_START_WAVE = 4
RUBBERBAND_FUND_SCALE = 1.1
PLAYTEST = true
TURBO_TESTING = false
GODMODE_TEST = false
G_WAVE_INDEX = -1

WAYPOINTS = {}
local rad = 2875

WAYPOINTS[0] = Vector(rad, 0)
WAYPOINTS[1] = Vector(rad, -rad)
WAYPOINTS[2] = Vector(0, -rad)
WAYPOINTS[3] = Vector(-rad, -rad)
WAYPOINTS[4] = Vector(-rad, 0)
WAYPOINTS[5] = Vector(-rad, rad)
WAYPOINTS[6] = Vector(0, rad)
WAYPOINTS[7] = Vector(rad, rad)

ITEMS_TIER =
{
  {"item_quarterstaff", "item_gloves", "item_orb_of_venom", "item_relic", "item_demon_edge", "item_blight_stone"},
  {"item_maelstrom", "item_desolator","item_basher", "item_skadi", "item_radiance", "item_monkey_king_bar", "item_dragon_lance"},
  {"item_lesser_crit", "item_octarine_core", "item_abyssal_blade", "item_hyperstone", "item_rapier", "item_echo_sabre"},
  {"item_moon_shard", "item_assault", "item_mjollnir", "item_greater_crit", "item_vladmir", "item_bfury"}
}

--GLOBAL_lock(_G)