-- This is the entry-point to your game mode and should be used primarily to precache models/particles/sounds/etc

require('internal/util')
require('gamemode')




function Precache( context )
--[[
  This function is used to precache resources/units/items/abilities that will be needed
  for sure in your game and that will not be precached by hero selection.  When a hero
  is selected from the hero selection screen, the game will precache that hero's assets,
  any equipped cosmetics, and perform the data-driven precaching defined in that hero's
  precache{} block, as well as the precache{} block for any equipped abilities.

  See GameMode:PostLoadPrecache() in gamemode.lua for more information
  ]]

  DebugPrint("[BAREBONES] Performing pre-load precache")

  PrecacheResource("particle", PARTICLE_ROSHAN_SMOKE, context)
  PrecacheResource("particle", PARTICLE_ROSHAN_EXPLOSION, context)

  PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_ogre_magi.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_ogre_magi.vsndevts", context)

  PrecacheResource("soundfile", "soundevents/game_sounds_roshan_halloween.vsndevts", context)

  PrecacheModel("models/props_structures/dire_fountain001.vmdl", context)
  PrecacheModel("models/props_gameplay/crown001.vmdl", context)
  
  PrecacheUnitByNameSync("npc_dota_tower_location", context)
  PrecacheUnitByNameSync("npc_slot_gold_greevil", context)
  PrecacheUnitByNameSync("npc_slot_frog", context)
  PrecacheUnitByNameSync("npc_slot_lockjaw", context)
  PrecacheUnitByNameSync("npc_slot_trapjaw", context)
  PrecacheUnitByNameSync("npc_slot_mega_greevil", context)
  PrecacheUnitByNameSync("npc_slot_sheep", context)
  PrecacheUnitByNameSync("npc_slot_present", context)
  PrecacheUnitByNameSync("npc_slot_treasure_chest", context)
  PrecacheUnitByNameSync("npc_slot_branch", context)
  PrecacheUnitByNameSync("npc_dota_custom_mine", context)

  --//START_OF_GENERATED_TOWER_PRECACHE

  PrecacheUnitByNameSync("tower_abyssal_underlord", context)
  PrecacheUnitByNameSync("tower_abyssal_underlord2", context)
  PrecacheUnitByNameSync("tower_crystal_maiden", context)
  PrecacheUnitByNameSync("tower_crystal_maiden2", context)
  PrecacheUnitByNameSync("tower_dragon_knight", context)
  PrecacheUnitByNameSync("tower_dragon_knight2", context)
  PrecacheUnitByNameSync("tower_ember_spirit", context)
  PrecacheUnitByNameSync("tower_ember_spirit2", context)
  PrecacheUnitByNameSync("tower_gyrocopter", context)
  PrecacheUnitByNameSync("tower_gyrocopter2", context)
  PrecacheUnitByNameSync("tower_kunkka", context)
  PrecacheUnitByNameSync("tower_kunkka2", context)
  PrecacheUnitByNameSync("tower_life_stealer", context)
  PrecacheUnitByNameSync("tower_luna", context)
  PrecacheUnitByNameSync("tower_luna2", context)
  PrecacheUnitByNameSync("tower_medusa", context)
  PrecacheUnitByNameSync("tower_medusa2", context)
  PrecacheUnitByNameSync("tower_nevermore", context)
  PrecacheUnitByNameSync("tower_nevermore2", context)
  PrecacheUnitByNameSync("tower_phantom_assassin", context)
  PrecacheUnitByNameSync("tower_phantom_assassin2", context)
  PrecacheUnitByNameSync("tower_sniper", context)
  PrecacheUnitByNameSync("tower_sniper2", context)
  PrecacheUnitByNameSync("tower_spirit_breaker", context)
  PrecacheUnitByNameSync("tower_spirit_breaker2", context)
  PrecacheUnitByNameSync("tower_sven", context)
  PrecacheUnitByNameSync("tower_sven2", context)
  PrecacheUnitByNameSync("tower_techies", context)
  PrecacheUnitByNameSync("tower_techies2", context)
  PrecacheUnitByNameSync("tower_templar_assassin", context)
  PrecacheUnitByNameSync("tower_templar_assassin2", context)
  PrecacheUnitByNameSync("tower_ursa", context)
  PrecacheUnitByNameSync("tower_ursa2", context)
  PrecacheUnitByNameSync("tower_venomancer", context)
  PrecacheUnitByNameSync("tower_venomancer2", context)
  PrecacheUnitByNameSync("tower_warlock", context)
  PrecacheUnitByNameSync("tower_warlock2", context)
  PrecacheUnitByNameSync("tower_weaver", context)
  PrecacheUnitByNameSync("tower_weaver2", context)
  PrecacheUnitByNameSync("tower_windrunner", context)
  PrecacheUnitByNameSync("tower_windrunner2", context)
  PrecacheUnitByNameSync("tower_windrunner3", context)
  PrecacheUnitByNameSync("tower_wisp", context)
  PrecacheUnitByNameSync("tower_witch_doctor", context)
  PrecacheUnitByNameSync("tower_witch_doctor2", context)
  PrecacheUnitByNameSync("tower_zuus", context)
  PrecacheUnitByNameSync("tower_zuus2", context)
  --//END_OF_GENERATED_TOWER_PRECACHE

  local WAVES = require('waves')

  for i = 1, #WAVES.waveTable do
    PrecacheUnitByNameSync(WAVES.waveTable[i].creep, context)
  end

  PrecacheUnitByNameSync("last_unit_p", context)

end

-- Create the game mode when we activate
function Activate()
  GameRules.GameMode = GameMode()
  GameRules.GameMode:_InitGameMode()
end































