-- This is the primary barebones gamemode script and should be used to assist in initializing your game mode
BAREBONES_VERSION = "1.00"

-- Set this to true if you want to see a complete debug output of all events/processes done by barebones
-- You can also change the cvar 'barebones_spew' at any time to 1 or 0 for output/no output
BAREBONES_DEBUG_SPEW = false

local function lock_new_member(t, k, v)
  print("warning adding new GameMode member after init: " .. k)
  if t.oldnewindex then
    t.oldnewindex(t, k, v)
  end
end 

if GameMode == nil then
    DebugPrint( '[BAREBONES] creating barebones game mode' )
    _G.GameMode = class({})
end

-- This library allow for easily delayed/timed actions
require('libraries/timers')
-- This library can be used for advancted physics/motion/collision of units.  See PhysicsReadme.txt for more information.
--require('libraries/physics')
-- This library can be used for advanced 3D projectile systems.
--require('libraries/projectiles')
-- This library can be used for sending panorama notifications to the UIs of players/teams/everyone
require('libraries/notifications')
-- This library can be used for starting customized animations on units from lua
require('libraries/animations')
-- This library can be used for performing "Frankenstein" attachments on units
--require('libraries/attachments')
-- This library can be used to synchronize client-server data via player/client-specific nettables
--require('libraries/playertables')
-- This library can be used to create container inventories or container shops
--require('libraries/containers')
-- This library provides a searchable, automatically updating lua API in the tools-mode via "modmaker_api" console command
--require('libraries/modmaker')
-- This library provides an automatic graph construction of path_corner entities within the map
require('libraries/pathgraph')
-- This library (by Noya) provides player selection inspection and management from server lua
--require('libraries/selection')

-- These internal libraries set up barebones's events and processes.  Feel free to inspect them/change them if you need to.
require('internal/gamemode')
require('internal/events')

-- settings.lua is where you can specify many different properties for your game mode and is one of the core barebones files.
require('settings')
-- events.lua is where you can specify the actions to be taken when any event occurs and is one of the core barebones files.
require('events')

require('globals')
require('util_functions')
require('playergamestate')
require('loadingscreen_settings')
require('slotmachine')
require('tower')
require('targeting')
require('unit_scripts/ai_shared_code')
require('unit_scripts/ai_boss_pathing')
require('donations')

PARTICLE_ROSHAN_SMOKE = "particles/dire_fx/bad_ancient_smoke.vpcf"
PARTICLE_ROSHAN_EXPLOSION = "particles/neutral_fx/roshan_slam_blast.vpcf"

--[[
  This function should be used to set up Async precache calls at the beginning of the gameplay.

  In this function, place all of your PrecacheItemByNameAsync and PrecacheUnitByNameAsync.  These calls will be made
  after all players have loaded in, but before they have selected their heroes. PrecacheItemByNameAsync can also
  be used to precache dynamically-added datadriven abilities instead of items.  PrecacheUnitByNameAsync will 
  precache the precache{} block statement of the unit and all precache{} block statements for every Ability# 
  defined on the unit.

  This function should only be called once.  If you want to/need to precache more items/abilities/units at a later
  time, you can call the functions individually (for example if you want to precache units in a new wave of
  holdout).

  This function should generally only be used if the Precache() function in addon_game_mode.lua is not working.
]]
function GameMode:PostLoadPrecache()
  DebugPrint("[BAREBONES] Performing Post-Load precache")    
  --PrecacheItemByNameAsync("item_example_item", function(...) end)
  --PrecacheItemByNameAsync("example_ability", function(...) end)

  --PrecacheUnitByNameAsync("npc_dota_hero_viper", function(...) end)
  --PrecacheUnitByNameAsync("npc_dota_hero_enigma", function(...) end)
end

-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function GameMode:InitGameMode()
  GameMode = self

  DebugPrint('[BAREBONES] Starting to load Barebones gamemode...')
  DebugPrint('[BAREBONES] Done loading Barebones gamemode!\n\n')

  --GLOBAL_lock(_G)

  --for settings screen and loadscreen testing
  --GameRules:SetCustomGameSetupTimeout( 60 * 60 * 4)
  --GameRules:SetCustomGameSetupAutoLaunchDelay(60*60*4)

  LinkLuaModifier( "modifier_super_speed_lua", "modifier_super_speed.lua", LUA_MODIFIER_MOTION_NONE )

  LimitPathingSearchDepth(1/1000)

  self.WAVES = require('waves')
  self.numCreepsAlive = 0
  self.numCreepsSpawned = 0
  self.inSpawnMode = false
  self.vPlayers = {}
  self.startTime = 10
  self.currentWave = 0
  self.numLives = 30
  self.gameInProgress = false
  self.plusVoteInProgress = false
  self.plusVoteCompleted = false
  self.waveCount = #self.WAVES.waveTable
  self.playerColors = {}
  self.playerNameToHeroTable = {}
  self.scrambleLocationTable = {}
  self.rubberBandFund = 0
  self.playerNameToHeroTable = {}
  self.gameTickInterval = 1.0/2.0
  self.dropOneItem = false
  self.waveCreatureList = {}

  self.playerColors[1] = { 197, 77, 168 }   --    Pink
  self.playerColors[2] = { 52, 85, 255 }    --    Blue
  self.playerColors[3] = { 255, 108, 0 }    --    Orange
  self.playerColors[4] = { 100, 255, 13 }   --    Greenish
  self.playerColors[5] = { 255, 40, 20 }    --    Red
  self.playerColors[6] = { 50, 50, 60 }     --    Black
  self.playerColors[7] = { 140, 42, 244 }   --    Purple
  self.playerColors[8] = { 129, 83, 54 }    --    Brown

  self.slotmachine = SlotMachine:new()
  self.slotmachine:Init()

  self.cTowerRadius = 150
  self.cHalfWidth = 2500
  self.cWidth = self.cHalfWidth*2
  self.cNumTowersLongPart = 16
  self.cNumRanks = 3
  self.cNumTowersShortPart = self.cNumTowersLongPart - self.cNumRanks
  self.firstConnectFull = true

  --
  local mt = getmetatable(self)

  self.oldnewindex = mt.__newindex

  --PrintTable(mt)
  mt.__newindex = lock_new_member
  setmetatable(self, mt)

  CustomGameEventManager:RegisterListener( "Try_Press_Setting_Button", TryPressSettingsButtonEvent)
  CustomGameEventManager:RegisterListener( "Try_Press_Toggle", TryPressToggle)
  CustomGameEventManager:RegisterListener( "CastPlusVote", CastPlusVote)
  CustomGameEventManager:RegisterListener( "Player_Picks_Color", PlayerPicksColor)
  CustomGameEventManager:RegisterListener( "RequestTopTenDonations", RequestTopTenDonations)

  GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(GameMode, 'OrderFilter'), self)



end

function GameMode:OnConnectFull(keys)
  --print("GameMode:OnConnectFull(keys)")
  --PrintTable(keys)

  if self.firstConnectFull == true then
    --GetDonations()
    self.firstConnectFull = false
  end
  
end

--[[
  This function is called once and only once as soon as the first player (almost certain to be the server in local lobbies) loads in.
  It can be used to initialize state that isn't initializeable in InitGameMode() but needs to be done before everyone loads in.
]]
function GameMode:OnFirstPlayerLoaded()
  DebugPrint("[BAREBONES] First Player has loaded")
end

--[[
  This function is called once and only once after all players have loaded into the game, right as the hero selection time begins.
  It can be used to initialize non-hero player state or adjust the hero selection (i.e. force random etc)
]]
function GameMode:OnAllPlayersLoaded()
  DebugPrint("[BAREBONES] All Players have loaded into the game")


end

--[[
  This function is called once and only once for every player when they spawn into the game for the first time.  It is also called
  if the player's hero is replaced with a new hero for any reason.  This function is useful for initializing heroes, such as adding
  levels, changing the starting gold, removing/adding abilities, adding physics, etc.

  The hero parameter is the hero entity that just spawned in
]]
function GameMode:OnHeroInGame(hero)
  DebugPrint("[BAREBONES] Hero spawned in game for first time -- " .. hero:GetUnitName())

  if hero.PGS ~= nil then
    print("Warning: GameMode:OnHeroInGame(hero) ran more than once for hero")
    return
  end

  if #self.vPlayers == 0 then
    self:OnFirstHeroInGame(hero)
  end

  for i = 0, hero:GetAbilityCount()-1 do
    local a = hero:GetAbilityByIndex(i)
    if a ~= nil then
      hero:RemoveAbility(a:GetAbilityName())
    end
  end
  
  hero:SetGold(INCOME_START_GOLD_DIFFICULTY[DIFFICULTY], false)
  hero:SetAbilityPoints(0)
  hero:SetCanSellItems(false)
  hero:AddNewModifier(hero, nil, "modifier_super_speed_lua", nil)

  hero:AddAbility("slot_spin")
  hero:AddAbility("slot_spin2")
  hero:AddAbility("sell_items")


  local a = hero:FindAbilityByName("slot_spin")
  a:StartCooldown(80.0)
  a:SetLevel(1)

  a = hero:FindAbilityByName("slot_spin2")
  a:StartCooldown(80.0)
  a:SetLevel(1)

  a = hero:FindAbilityByName("sell_items")
  a:SetLevel(1)

  --here we init members to the hero table
  hero.PGS = PlayerGameState:new(hero:GetPlayerID())

  self.playerNameToHeroTable[hero.PGS.playerName] = hero

  table.insert(self.vPlayers, hero)

  local randomColor = math.random(1, #self.playerColors)

  if hero.PGS:IsDev() then
    hero.PGS.customColor = {225, 235, 255}
    hero.PGS.customColor = self.playerColors[randomColor]
    hero:SetModelScale(1.4)
    Notifications:Top(hero:GetPlayerID(), {text="DEV: HELLO DEV!", duration=10, style={color="red"}, continue=false})

    local icon = Entities:CreateByClassname("prop_dynamic")
    icon:SetModel("models/props_gameplay/crown001.vmdl")
    icon:SetParent(hero:GetRootMoveParent(), "attach_cast4_primal_roar")
    icon:SetRenderColor(hero.PGS.customColor[1], hero.PGS.customColor[2], hero.PGS.customColor[3])
    icon:SetOrigin(Vector(-20, 0, 18))
    icon:SetModelScale(0.75)

    
    hero:AddAbility("stopistop")
    a = hero:FindAbilityByName("stopistop")
    a:SetLevel(1)
  else
    hero.PGS.customColor = self.playerColors[randomColor]

    local icon = Entities:CreateByClassname("prop_dynamic")
    icon:SetModel("models/props_structures/dire_fountain001.vmdl")
    icon:SetParent(hero:GetRootMoveParent(), "attach_cast4_primal_roar")
    icon:SetRenderColor(hero.PGS.customColor[1], hero.PGS.customColor[2], hero.PGS.customColor[3])
    icon:SetOrigin(Vector(0, 0, 64))

  end

  PlayerResource:SetCustomPlayerColor(hero:GetPlayerID(), hero.PGS.customColor[1], hero.PGS.customColor[2], hero.PGS.customColor[3])


  table.remove(self.playerColors, randomColor)

  if #self.vPlayers == 1 then
    hero:SetAbsOrigin(Vector(0, 2500, 244))
  elseif #self.vPlayers == 2 then
    hero:SetAbsOrigin(Vector(2500, 0))
  elseif #self.vPlayers == 3 then
    hero:SetAbsOrigin(Vector(0, -2500))
  else
    hero:SetAbsOrigin(Vector(-2500, 0))
  end

  self:CreateTowerSlotsForPlayer(hero, #self.vPlayers)

  Notifications:Bottom(hero:GetPlayerID(), {text="#startTutorial", duration=PRE_GAME_TIME-3, style={color="yellow", ["font-size"]="42px", ["text-shadow"]="2px 2px 2px #98101E", ["background-color"]="#222222DD"}})


  --init netTable
  CustomNetTables:SetTableValue( "players_nTowers", "player" .. hero:GetPlayerID(), {value = 0} )
  CustomNetTables:SetTableValue( "players_SpinBalance", "player" .. hero:GetPlayerID(), {value = 0} )
  CustomNetTables:SetTableValue( "players_Networth", "player" .. hero:GetPlayerID(), {value = 0} )
end

function GameMode:OnFirstHeroInGame(hero)
  
  Timers:CreateTimer(2, function() SendDonationsBannerToAll() return end)

  if PLAYTEST and PlayerResource:GetPlayerCount() > 1 then
    PLAYTEST = false--turn of playtest if more than one player
  end

  if PLAYTEST then
    self:SpawnAllItems(hero:GetAbsOrigin() + Vector(600, -600, 0))
  end

  self.numLives = START_LIVES_DIFFICULTY[DIFFICULTY]

  if GAMEMODE == GAMEMODE_SCRAMBLE then
    Entities:FindByName ( nil, "speed_lane_0" ).isSpeedOn = false
    Entities:FindByName ( nil, "speed_lane_1" ).isSpeedOn = false
    Entities:FindByName ( nil, "speed_lane_2" ).isSpeedOn = false
    Entities:FindByName ( nil, "speed_lane_3" ).isSpeedOn = false
  else
    Entities:FindByName ( nil, "speed_lane_0" ).isSpeedOn = true
    Entities:FindByName ( nil, "speed_lane_1" ).isSpeedOn = true
    Entities:FindByName ( nil, "speed_lane_2" ).isSpeedOn = true
    Entities:FindByName ( nil, "speed_lane_3" ).isSpeedOn = true
  end

  if GAMEMODE == 2 then--SCRAMBLE fill the ScrambleLocationTable
    for currentSide = 1, 4 do
      self.scrambleLocationTable[currentSide] = {}
      for r = 0, self.cNumRanks-1 do
        for x = 0, self.cNumTowersLongPart-1 do
          local vec = Vector(-self.cHalfWidth + (x*self.cTowerRadius), self.cHalfWidth - (r*self.cTowerRadius))

          for i = 1, currentSide-1 do
            vec = Vector(vec.y, -vec.x)
          end

          table.insert(self.scrambleLocationTable[currentSide], vec)
        end

        for x = 0, self.cNumTowersShortPart-1 do
          local vec = Vector(self.cHalfWidth - (x*self.cTowerRadius) - (self.cNumRanks*self.cTowerRadius), self.cHalfWidth - (r*self.cTowerRadius))

          for i = 1, currentSide-1 do
            vec = Vector(vec.y, -vec.x)
          end

          table.insert(self.scrambleLocationTable[currentSide], vec)
        end
      end
    end
  end

end

--[[
  This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
  gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.  This function
  is useful for starting any game logic timers/thinkers, beginning the first round, etc.
]]
function GameMode:OnGameInProgress()
  DebugPrint("[BAREBONES] The game has officially begun")

  CustomGameEventManager:Send_ServerToAllClients("DifficultyEvent", {difficulty = DIFFICULTY, plusLvl = PLUS_MODE_LEVEL} )
  CustomGameEventManager:Send_ServerToAllClients("QuestLifeUpdate", {value = self.numLives})
  
  if PLAYTEST and #self.vPlayers == 1 then
    Entities:FindByName ( nil, "speed_lane_0" ).isSpeedOn = TURBO_TESTING
    Entities:FindByName ( nil, "speed_lane_1" ).isSpeedOn = TURBO_TESTING
    Entities:FindByName ( nil, "speed_lane_2" ).isSpeedOn = TURBO_TESTING
    Entities:FindByName ( nil, "speed_lane_3" ).isSpeedOn = TURBO_TESTING
  end

  Timers:CreateTimer(1, function() self:FindTargets() return 0.33 end)

  Timers:CreateTimer(self.gameTickInterval, function() return self:GameTick() end)
  Timers:CreateTimer(1, function() return self:MoveCreepsIfTheyStop() end)
end

function GameMode:MoveCreepsIfTheyStop()

  for k, creep in pairs(self.waveCreatureList) do

    if creep:IsNull() == false and creep:IsAlive() == true then

      local pos = WAYPOINTS[creep.moveIndex]

      if creep.bMovingToCenter == true then
        pos = Entities:FindByName ( nil, "waypoint_end" )
      end

      local order = {
          UnitIndex = creep:GetEntityIndex(),
          OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
          Position = pos,
          Queue = true
      }

      ExecuteOrderFromTable(order)

    end
  end
  
  return 2
end

function GameMode:GameTick()
  local nPlayers = #self.vPlayers

  if self.plusVoteInProgress then

    if self.plusVoteCompleted then

      local yesVotes = 0

      for k, v in pairs(PLUS_VOTE_STATUS) do
        if v == 1 then
          yesVotes = yesVotes + 1
        end
      end

      if PLAYTEST and yesVotes == 1 then
        yesVotes = 4
      end

      if PLUS_MODE_VOTE_ENABLED == false then
        yesVotes = 4
      end

      if yesVotes >= self:numberOfActivePlayers() then --Start the next plusmode level

        self.currentWave = 0
        PLUS_MODE_LEVEL = PLUS_MODE_LEVEL + 1
        CustomGameEventManager:Send_ServerToAllClients("DifficultyEvent", {difficulty = DIFFICULTY, plusLvl = PLUS_MODE_LEVEL} )

        self.plusVoteInProgress = false
        self.plusVoteCompleted = true

      else -- Gj you won
        GameRules:SetGameWinner( DOTA_TEAM_GOODGUYS )
        Timers:RemoveTimers(true)
        return nil
      end

    else
      return 0.5
    end

  end

  if PLAYTEST then
    nPlayers = 4
  end

  if self.currentWave > 0 and self.numCreepsSpawned < self.WAVES.waveTable[self.currentWave].numTotal*self:numberOfActivePlayers() and self.inSpawnMode == true then
    if PLAYTEST then
      self:SpawnWave(self.currentWave, "spawn3", 6)--North
      self:SpawnWave(self.currentWave, "spawn0", 0)--East
      self:SpawnWave(self.currentWave, "spawn1", 2)--South
      self:SpawnWave(self.currentWave, "spawn2", 4)--West
    else
      local activePlayers = self:getActivePlayers()
      for i = 1, #activePlayers do
          self:SpawnWave(self.currentWave, activePlayers[i].PGS.spawnerName, activePlayers[i].PGS.spawnerOffset)
      end
    end
  end

  --is wave over
  if self.numCreepsAlive == 0 then
    self.inSpawnMode = true
    self.numCreepsSpawned = 0
    self.currentWave = self.currentWave + 1
    self.waveCreatureList = {}
    G_WAVE_INDEX = self.currentWave

    --have we reached the last wave?
    if self.currentWave > self.waveCount then
      if PLUS_MODE_ENABLED then

        if PLUS_MODE_LEVEL == #PLUS_MODE_BONUSES then
          GameRules:SetGameWinner( DOTA_TEAM_GOODGUYS )
          Timers:RemoveTimers(true)
          return nil
        else

          if PLUS_MODE_VOTE_ENABLED then
            CustomGameEventManager:Send_ServerToAllClients("PlusModeVoteStart", nil )
            self.plusVoteInProgress = true
            self.plusVoteCompleted = false

            Timers:CreateTimer(20, function()
            print("VOTE COMPLETE")
            self.plusVoteCompleted = true
            return nil
            end)

            return 0.5
          else
            self.plusVoteCompleted = true
            self.plusVoteInProgress = true

            return 2.0
          end
        end

      else
        GameRules:SetGameWinner( DOTA_TEAM_GOODGUYS )
        Timers:RemoveTimers(true)
        return nil
      end
    end

    --send boss msg and prepare item drop
    if self.WAVES.waveTable[self.currentWave].isBoss then
      Notifications:TopToAll({text= '#' .. self.WAVES.waveTable[self.currentWave].creep, duration=5.0})

      self.dropOneItem = true
    else
      self.dropOneItem = false
    end

    if self.currentWave ~= 1 then
      self:EndOfWavePayouts()
    end

    --handle dc players stun/unstun their towers etc
    self:HandleDisconnectedPlayers()

    Notifications:TopToAll({text="#wave_notifier " .. self.currentWave, duration=5.0})
    CustomGameEventManager:Send_ServerToAllClients("QuestWaveUpdate", {wave = self.currentWave, alive = self.WAVES.waveTable[self.currentWave].numTotal*self:numberOfActivePlayers()})
  end

  return self.gameTickInterval
end

--does not run at start of wave 1
function GameMode:EndOfWavePayouts()
  if self:useRubberBand() and not PLAYTEST then
 
    local activePlayers = self:getActivePlayers()

    table.sort(activePlayers, playerNetworthSort)

    --if RUBBERBAND_FUND_SCALE >= 1, this introduces gold into the system careful might make the game easier
    self.rubberBandFund = self.rubberBandFund * RUBBERBAND_FUND_SCALE

    if     self:numberOfActivePlayers() == 4 then
      activePlayers[1]:ModifyGold(math.ceil(self.rubberBandFund * 0.7), true, 0)
      activePlayers[2]:ModifyGold(math.ceil(self.rubberBandFund * 0.25), true, 0)
      activePlayers[3]:ModifyGold(math.ceil(self.rubberBandFund * 0.05), true, 0)
    elseif self:numberOfActivePlayers() == 3 then
      activePlayers[1]:ModifyGold(math.ceil(self.rubberBandFund * 0.8), true, 0)
      activePlayers[2]:ModifyGold(math.ceil(self.rubberBandFund * 0.2), true, 0)
    elseif self:numberOfActivePlayers() == 2 then
      activePlayers[1]:ModifyGold(self.rubberBandFund, true, 0)
    else
      activePlayers[1]:ModifyGold(self.rubberBandFund, true, 0)
    end

    local activeDevs = self:getActiveDevPlayers()

    for k, dev in pairs(activeDevs) do
      Notifications:Top(dev:GetPlayerID(), {text="DEV: Total rubberBandFund: " .. self.rubberBandFund, duration=10, style={color="red"}, continue=false})
    end

    self.rubberBandFund = 0
  end

  for k, hero in pairs(self.vPlayers) do
    if self:numberOfActivePlayers() < 4 then
      hero:ModifyGold((4-self:numberOfActivePlayers())*INCOME_MISSING_PLAYER_DIFFICULTY[DIFFICULTY], true, 0)
    end

    hero:ModifyGold(INCOME_FLAT_BY_DIFFICULTY[DIFFICULTY], true, 0)
    hero:ModifyGold(self.WAVES.waveTable[self.currentWave - 1].bonusEndGold * INCOME_WAVE_DIFFICULTY_MODIFIER[DIFFICULTY], true, 0)
  end
end

function GameMode:HandleDisconnectedPlayers()
  for k, hero in pairs(self.vPlayers) do
    if hero.PGS.stunPlayerUnitsNextTurn then

      if hero.PGS.spawnerDisabled == false then
        --stun all towers
        for i = 1, #hero.PGS.towerList do
          if hero.PGS.towerList[i] ~= nil then
            hero.PGS.towerList[i]:AddNewModifier(hero.PGS.towerList[i], nil, "modifier_earthshaker_fissure_stun", nil)
          end
        end

        --turn on the speed lane
        if GAMEMODE ~= GAMEMODE_SCRAMBLE then
          hero.PGS.speedLane.isSpeedOn = true

          --turn on entrance blockers
          if hero.PGS.entranceBlockers ~= nil then
            for k, value in pairs(hero.PGS.entranceBlockers) do
              if value ~= nil then
                value:SetEnabled(true, true)
              end
            end
          end
        end
      end

      --turn of spawner
      hero.PGS.spawnerDisabled = true
    else
      if hero.PGS.spawnerDisabled == true then
        --unstun all towers
        for i = 1, #hero.PGS.towerList do
          if hero.PGS.towerList[i] ~= nil then
            hero.PGS.towerList[i]:RemoveModifierByName("modifier_earthshaker_fissure_stun")
          end
        end

        --turn off the speed lane
        if hero.PGS.speedLane ~= nil then
          hero.PGS.speedLane.isSpeedOn = false
        end

        --turn off entrance blockers
        if hero.PGS.entranceBlockers ~= nil then
          for k, value in pairs(hero.PGS.entranceBlockers) do
            if value ~= nil then
              value:SetEnabled(false, true)
            end
          end
        end
      end
      --turn on spawner
      hero.PGS.spawnerDisabled = false
    end
  end
end

function GameMode:SpawnWave(waveIndex, spawnName, PathOffset)

  local SpawnLocation = Entities:FindByName( nil, spawnName)
  local waypointlocation = Entities:FindByName ( nil, "waypoint_end" )

  for n = 1, self.WAVES.waveTable[waveIndex].numPerSpawn do

    local CreateSpawnCallback = function(creature)  
      creature:SetHullRadius(0)
      creature:AddNewModifier(creature, nil, "modifier_super_speed_lua", nil)
      creature:AddNewModifier(creature, nil, "modifier_spectre_spectral_dagger_path_phased", nil)--{duration = 1})

      local hpBonus = PLUS_MODE_BONUSES[PLUS_MODE_LEVEL].hpBonusCreepStart + (self.currentWave * PLUS_MODE_BONUSES[PLUS_MODE_LEVEL].hpBonusCreepPT)

      if self.WAVES.waveTable[self.currentWave].isBoss then
        hpBonus = PLUS_MODE_BONUSES[PLUS_MODE_LEVEL].hpBonusBossStart + (self.currentWave * PLUS_MODE_BONUSES[PLUS_MODE_LEVEL].hpBonusBossPT)
        creature.PathOffset = PathOffset

        Timers:CreateTimer(0.1, function() return AI_MoveBoss(creature) end)
      end

      creature:SetBaseMaxHealth((creature:GetBaseMaxHealth() + hpBonus)*MAX_HEALTH_MULT_DIFFICULTY[DIFFICULTY])

      creature:SetMaxHealth(creature:GetBaseMaxHealth())
      creature:SetHealth(creature:GetMaxHealth())
      creature:SetPhysicalArmorBaseValue(creature:GetPhysicalArmorBaseValue() + PLUS_MODE_BONUSES[PLUS_MODE_LEVEL].armorBonus)

      creature:SetMaximumGoldBounty(creature:GetMaximumGoldBounty() + PLUS_MODE_BONUSES[PLUS_MODE_LEVEL].bountyBonus)
      creature:SetMinimumGoldBounty(creature:GetMinimumGoldBounty() + PLUS_MODE_BONUSES[PLUS_MODE_LEVEL].bountyBonus)

      if PLAYTEST == false and self:numberOfActivePlayers() < 4 then
        creature:ModifyHealth(creature:GetMaxHealth() * (self:numberOfActivePlayers()/4.0), nil, false, DOTA_DAMAGE_FLAG_HPLOSS)
      end

      creature.TD_Creep = true
      creature.moveIndex = PathOffset
      creature.moveStartIndex = nil
      creature.moveWaypointVisits = {0,0,0,0,0,0,0,0}

      table.insert(self.waveCreatureList, creature)

      if true then
        local pos = WAYPOINTS[PathOffset]

        local order = {
            UnitIndex = creature:GetEntityIndex(),
            OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
            Position = pos,
            Queue = true
        }

        ExecuteOrderFromTable(order)
      else--NOTE: old queue movement, creeps started stoping randomly after patch in 2017.05.xx
        if self.WAVES.waveTable[self.currentWave].isBoss == false then

          local dir = 8

          for i = 0, dir do

            local Ti = i
            if waveIndex % 2 == 0 then
              Ti = -Ti
            end

            local index = (PathOffset + Ti)%8

            local pos = WAYPOINTS[index]

            local order = {
                UnitIndex = creature:GetEntityIndex(),
                OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
                Position = pos,
                Queue = true
            }

            ExecuteOrderFromTable(order)
          end


          local finalOrder = {
              UnitIndex = creature:GetEntityIndex(),
              OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
              Position = waypointlocation,
              Queue = true
          }

          ExecuteOrderFromTable(finalOrder)
        end
      end
    end

    
    Timers:CreateTimer(0.15*(n-1), function() CreateUnitByNameAsync( self.WAVES.waveTable[waveIndex].creep , SpawnLocation:GetAbsOrigin() + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_NEUTRALS, CreateSpawnCallback) end)

    self.numCreepsAlive = self.numCreepsAlive + 1
    self.numCreepsSpawned = self.numCreepsSpawned + 1

  end
end

function GameMode:TD_CreepKilled(creep, attacker)
  self.numCreepsAlive = self.numCreepsAlive - 1
  CustomGameEventManager:Send_ServerToAllClients("QuestWaveUpdate", {wave = self.currentWave, alive = self.numCreepsAlive})

  if self.dropOneItem and attacker ~= creep then
    self:DropBossLoot(killerEntity)
  end

  --creep reached center
  if attacker == creep then
    self.numLives = self.numLives - self.WAVES.waveTable[self.currentWave].lifePenalty
    CustomGameEventManager:Send_ServerToAllClients("QuestLifeUpdate", {value = self.numLives})

  elseif attacker:GetOwner() ~= nil then
    local hero = nil

    if attacker:IsRealHero() then
      hero = attacker
    else
      hero = attacker:GetOwner()

      if hero.IS_PLAYTEST_MIRROR == true then
        return
      end

      if not hero:IsRealHero() then
        hero = hero:GetOwner()

        --all of this is needed for techies tower mines to yield bounties
        --[[
        local bountyFix = true

        if bountyFix then
          local bountyDummy = CreateUnitByName("npc_dummy_unit", creep:GetAbsOrigin(), false, nil, nil, DOTA_TEAM_NEUTRALS)

          bountyDummy:AddNoDraw()
          bountyDummy:SetMaximumGoldBounty(creep:GetMaximumGoldBounty())
          bountyDummy:SetMinimumGoldBounty(creep:GetMinimumGoldBounty())
          bountyDummy:SetHullRadius(0)
          bountyDummy:AddNewModifier(bountyDummy, nil, "modifier_item_phase_boots_active", nil)
          bountyDummy:AddNewModifier(bountyDummy, nil, "modifier_invulnerable", nil)
          bountyDummy:Kill(nil, hero)
          --Timers:CreateTimer(0.1, function() bountyDummy:Kill(nil, hero) return nil end)
        end

        --]]
      end
    end
    hero.PGS.nTDCreepKills = hero.PGS.nTDCreepKills + 1

    local player = hero

    if self:useRubberBand() and self:numberOfActivePlayers() > 1 and PLAYTEST == false then
      if self:isPlayerInBigLead(player:GetPlayerID()) then
        local hero = attacker:GetOwner()

        hero.PGS.leadTaxAcc = hero.PGS.leadTaxAcc + creep:GetGoldBounty()*0.65--/2.0--waveTable[self.currentWave].bigLeadTax

        while hero.PGS.leadTaxAcc > 1.0 do
          hero.PGS.leadTaxAcc = hero.PGS.leadTaxAcc - 1.0
          self.rubberBandFund = self.rubberBandFund + 1
          player:ModifyGold(-1, true, 0)
        end
      end
    end
  end

end

function GameMode:CreateTowerSlot(hero, location)
  local towerSlot = CreateUnitByName( "npc_dota_tower_location" , location, false, hero, hero, DOTA_TEAM_GOODGUYS)
  towerSlot:SetAbsOrigin(towerSlot:GetAbsOrigin() + Vector(0, 0, 16))
  towerSlot:SetAngles(0, -90, 0)
  towerSlot:SetControllableByPlayer(hero:GetPlayerID(), true)
  towerSlot:SetRenderColor(hero.PGS.customColor[1], hero.PGS.customColor[2], hero.PGS.customColor[3])
  towerSlot:AddNewModifier(towerSlot, nil, "modifier_invulnerable", nil)

  --towerSlot:AddNoDraw()

  local buildSlotProp = Entities:CreateByClassname("prop_dynamic")
  buildSlotProp:SetModel("models/heroes/pedestal/effigy_pedestal_ti5.vmdl")--caster:GetModelName())
  buildSlotProp:SetModelScale(0.85)
  buildSlotProp:SetRenderColor(hero.PGS.customColor[1], hero.PGS.customColor[2], hero.PGS.customColor[3])
  buildSlotProp:SetOrigin(towerSlot:GetAbsOrigin() + Vector(0, 0, 0))

  towerSlot.buildSlotProp = buildSlotProp

  table.insert(hero.PGS.towerPlatformsList, towerSlot)

  return towerSlot
end

function GameMode:CreateTowerSlotsForPlayer(hero, index)

  if     index == 1 then
    --north
    hero.PGS.spawnerName = "spawn3"
    hero.PGS.spawnerOffset = 6
    hero.PGS.speedLane = Entities:FindByName(nil, "speed_lane_3")
  elseif index == 2 then
    --east
    hero.PGS.spawnerName = "spawn0"
    hero.PGS.spawnerOffset = 0
    hero.PGS.speedLane = Entities:FindByName(nil, "speed_lane_0")
  elseif index == 3 then
    --south
    hero.PGS.spawnerName = "spawn1"
    hero.PGS.spawnerOffset = 2
    hero.PGS.speedLane = Entities:FindByName(nil, "speed_lane_1")
  elseif index == 4 then
    --west
    hero.PGS.spawnerName = "spawn2"
    hero.PGS.spawnerOffset = 4
    hero.PGS.speedLane = Entities:FindByName(nil, "speed_lane_2")
  end

  hero.PGS.speedLane.isSpeedOn = false

  if GAMEMODE == GAMEMODE_NORMAL then
    for r = 0, self.cNumRanks-1 do
      for x = 0, self.cNumTowersLongPart-1 do
        local vec = Vector(-self.cHalfWidth + (x*self.cTowerRadius), self.cHalfWidth - (r*self.cTowerRadius))

        for i = 1, index-1 do
          vec = Vector(vec.y, -vec.x)
        end

        self:CreateTowerSlot(hero, vec)
      end
      for x = 0, self.cNumTowersShortPart-1 do
        local vec = Vector(self.cHalfWidth - (x*self.cTowerRadius) - (self.cNumRanks*self.cTowerRadius), self.cHalfWidth - (r*self.cTowerRadius))

        for i = 1, index-1 do
          vec = Vector(vec.y, -vec.x)
        end
       
        self:CreateTowerSlot(hero, vec)
        end
    end
  elseif GAMEMODE == GAMEMODE_SCRAMBLE then
    for n = 1, (self.cNumTowersLongPart*self.cNumRanks + self.cNumTowersShortPart*self.cNumRanks) do
      local randSide = math.random(1, 4)

      while #self.scrambleLocationTable[randSide] == 0 do
        randSide = math.random(1, 4)
      end

      local randVecIndex = math.random(1, #self.scrambleLocationTable[randSide])
      local randVec = self.scrambleLocationTable[randSide][randVecIndex]

      self:CreateTowerSlot(hero, randVec)

      table.remove(self.scrambleLocationTable[randSide], randVecIndex)

    end
  end

end

function GameMode:DropBossLoot(killerEntity)

  local r = math.random(1, self.numCreepsAlive)

  if self.numCreepsAlive == 0 then
    r = self.numCreepsAlive
  end

  local BossLootMessageFunc = function(_hero, _itemReward)
    Notifications:Top(_hero.PGS.player,{ text = "#boss_loot", duration = 5, continue=false})
    Notifications:Top(_hero.PGS.player,{ text=_hero.PGS.playerName .. " ", duration=5, style={color="rgb(".. _hero.PGS.customColor[1] .. "," .. _hero.PGS.customColor[2] .. "," .. _hero.PGS.customColor[3] .. ")"}, continue=false})
    Notifications:Top(_hero.PGS.player,{ item=_itemReward, continue=true})
  end

  if r == self.numCreepsAlive then

    local itemPool = {}

    if self.currentWave <= 15 then

      table.insert(itemPool, GetRandomElement(ITEMS_TIER[1]))
      table.insert(itemPool, GetRandomElement(ITEMS_TIER[1]))
      table.insert(itemPool, GetRandomElement(ITEMS_TIER[2]))
      table.insert(itemPool, GetRandomElement(ITEMS_TIER[3]))

    elseif self.currentWave <= 25 then

      table.insert(itemPool, GetRandomElement(ITEMS_TIER[2]))
      table.insert(itemPool, GetRandomElement(ITEMS_TIER[3]))
      table.insert(itemPool, GetRandomElement(ITEMS_TIER[3]))
      table.insert(itemPool, GetRandomElement(ITEMS_TIER[4]))

    else

      table.insert(itemPool, GetRandomElement(ITEMS_TIER[3]))
      table.insert(itemPool, GetRandomElement(ITEMS_TIER[3]))
      table.insert(itemPool, GetRandomElement(ITEMS_TIER[4]))
      table.insert(itemPool, GetRandomElement(ITEMS_TIER[4]))

    end

    for k, hero in pairs(self:getActivePlayers()) do
      local randomIndex = math.random(1, #itemPool)
      local itemReward = itemPool[randomIndex]
      table.remove(itemPool, randomIndex)
      BossLootMessageFunc(hero, itemReward)

      if hero:GetNumItemsInInventory() < 6 then
        hero:AddItemByName(itemReward)
      else
        local newItem = CreateItem(itemReward, hero, hero)
        newItem:SetPurchaseTime(0)
        CreateItemOnPositionSync(hero:GetAbsOrigin(), newItem)
      end
      self:ItemTutorial(hero)

    end

    self.dropOneItem = false

  end

end

function GameMode:numberOfActivePlayers()
  local n = 0

  --might be the source of the bug where not enough creeps spawn.
  if PLAYTEST and  #self.vPlayers == 1 then
    return 4
  end

  for k,v in pairs(self.vPlayers) do

    if v.PGS.spawnerDisabled == false then
      n = n + 1
    end

  end

  return n
end

function GameMode:getActivePlayers()
  local activePlayers = {}

  for k,v in pairs(self.vPlayers) do

    if v.PGS.spawnerDisabled == false then
      table.insert(activePlayers, v)
    end

  end

  return activePlayers
end

function GameMode:getActiveDevPlayers()
  local activePlayers = self:getActivePlayers()
  local activeDevs = {}

  for k, v in pairs(activePlayers) do
    if v.PGS:IsDev() then
      table.insert(activeDevs, v)
    end
  end

  return activeDevs
end

function GameMode:getPlayerTotalNetworthPercentage(playerID)
  local totalNetworth = 0.0
  local playerNetworth = 0.0

  for k,v in pairs(self.vPlayers) do

    if v.PGS.spawnerDisabled == false then
      totalNetworth = totalNetworth + v.PGS.networth + v:GetGold()
    end

    if v:GetPlayerID() == playerID then
      playerNetworth = v.PGS.networth + v:GetGold()
    end

  end

  return playerNetworth/totalNetworth
end

function playerNetworthSort(a, b)
  return a.PGS.networth + a:GetGold() < b.PGS.networth + b:GetGold()
end

function GameMode:isPlayerInLastPlaceNetworth(playerID)

  local tempTable = self.vPlayers
  table.sort(tempTable, playerNetworthSort)

  return tempTable[1]:GetPlayerID() == playerID
end

function GameMode:isPlayerInBigLead(playerID)
  local percentage = self:getPlayerTotalNetworthPercentage(playerID)

  if self:numberOfActivePlayers() == 1 or PLAYTEST then
    return false
  end

  if  (self:numberOfActivePlayers() == 4 and percentage >= 0.28) or
      (self:numberOfActivePlayers() == 3 and percentage >= 0.35) or
      (self:numberOfActivePlayers() == 2 and percentage >= 0.55) then

    return true
  end

  return false
end

function GameMode:useRubberBand()
  return USE_RUBBERBAND and self.currentWave >= RUBBERBAND_START_WAVE
end

function GameMode:OrderFilter(keys)

  local unit = nil

  if keys.units ~= nil then
    --PrintTable(keys.units)
    if keys.units[tostring(0)] ~= nil then
      unit = EntIndexToHScript(keys.units[tostring(0)])
    end
  end

  if unit ~= nil and keys.issuer_player_id_const ~= unit:GetMainControllingPlayer() then
    return false
  end

  if keys.issuer_player_id_const >= 0  and keys.order_type == DOTA_UNIT_ORDER_HOLD_POSITION or keys.order_type == DOTA_UNIT_ORDER_STOP then
    --PrintTable(keys)
    --print("________________")
    --PrintTable(keys.units)

    --i use this to prevent players from making their towers idle(non aggresive)

    --both these 2 return 0 :/, thus the while loop construct below
    --print("#units: " .. #(keys.units))
    --print("table.getn: " .. table.getn(keys.units))

    local i = 0
    local e = keys.units[tostring(i)]

    while e ~= nil do
      --index as string otherwise i get nil values :/.
      
      unit = EntIndexToHScript(keys.units[tostring(i)])
      if unit.IsATower then
        --print("stop")

        return false
      end

      i = i + 1
      e = keys.units[tostring(i)]
    end
  end

  return true
end

function GameMode:ItemTutorial(hero)
  if hero.PGS.nItemRewards == 1 then
    Notifications:Bottom(hero:GetPlayerID(), {text="#itemTutorial", duration=15, style={color="yellow", ["font-size"]="42px", ["text-shadow"]="2px 2px 2px #98101E", ["background-color"]="#222222DD"}})
  end
end

function GameMode:SpawnAllItems(location)
  for y = 1, #ITEMS_TIER do
    for x = 1, #ITEMS_TIER[y] do
      local newItem = CreateItem(ITEMS_TIER[y][x], self.vPlayers[0], self.vPlayers[0])
      newItem:SetPurchaseTime(0)
      CreateItemOnPositionSync(location + Vector((x-1)*100, (y-1)*-200, 0), newItem)
    end
  end
end

function stopIStop(keys)
  --print("Gstopistop")
  --PrintTable(keys)
  keys.target:Interrupt()
  GameMode.numLives = 999999
end